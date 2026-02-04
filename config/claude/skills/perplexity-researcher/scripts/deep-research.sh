#!/bin/bash
# Perplexity Deep Research Async Helper
# Submits a deep research job and polls for results

set -e

API_KEY="${PERPLEXITY_API_KEY}"
BASE_URL="https://api.perplexity.ai"
POLL_INTERVAL=15  # seconds between polls
MAX_WAIT=600      # maximum wait time in seconds

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: deep-research.sh 'research query' [output_file]"
    echo ""
    echo "Arguments:"
    echo "  query        The research question (required)"
    echo "  output_file  Optional file to save results (default: stdout)"
    echo ""
    echo "Environment:"
    echo "  PERPLEXITY_API_KEY  Your Perplexity API key (required)"
    echo ""
    echo "Examples:"
    echo "  deep-research.sh 'Analyze the React vs Vue ecosystem in 2025'"
    echo "  deep-research.sh 'Market analysis of AI coding assistants' report.md"
    exit 1
}

# Check requirements
if [ -z "$API_KEY" ]; then
    echo -e "${RED}Error: PERPLEXITY_API_KEY environment variable not set${NC}"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed${NC}"
    echo "Install with: brew install jq"
    exit 1
fi

if [ -z "$1" ]; then
    usage
fi

QUERY="$1"
OUTPUT_FILE="${2:-}"

echo -e "${BLUE}=== Perplexity Deep Research ===${NC}"
echo -e "Query: ${YELLOW}$QUERY${NC}"
echo ""

# Create async job
echo -e "${BLUE}Submitting research job...${NC}"
RESPONSE=$(curl -s -X POST "${BASE_URL}/async/chat/completions" \
    -H "Authorization: Bearer ${API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{
        \"model\": \"sonar-deep-research\",
        \"messages\": [{\"role\": \"user\", \"content\": \"${QUERY}\"}]
    }")

REQUEST_ID=$(echo "$RESPONSE" | jq -r '.id // empty')

if [ -z "$REQUEST_ID" ]; then
    ERROR=$(echo "$RESPONSE" | jq -r '.error.message // .detail // "Unknown error"')
    echo -e "${RED}Error creating job: $ERROR${NC}"
    exit 1
fi

echo -e "${GREEN}Job created: $REQUEST_ID${NC}"
echo -e "Polling for results (this may take 2-5 minutes)..."
echo ""

# Poll for completion
START_TIME=$(date +%s)
DOTS=""

while true; do
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))

    if [ $ELAPSED -gt $MAX_WAIT ]; then
        echo -e "\n${RED}Timeout: Research took longer than expected${NC}"
        echo "Job ID: $REQUEST_ID"
        echo "You can check status later with:"
        echo "  curl -H \"Authorization: Bearer \$PERPLEXITY_API_KEY\" \\"
        echo "    ${BASE_URL}/async/chat/completions/${REQUEST_ID}"
        exit 1
    fi

    STATUS_RESPONSE=$(curl -s "${BASE_URL}/async/chat/completions/${REQUEST_ID}" \
        -H "Authorization: Bearer ${API_KEY}")

    STATE=$(echo "$STATUS_RESPONSE" | jq -r '.status // "unknown"')

    case "$STATE" in
        "completed")
            echo -e "\n${GREEN}Research complete!${NC}"
            echo ""

            CONTENT=$(echo "$STATUS_RESPONSE" | jq -r '.choices[0].message.content // "No content"')
            CITATIONS=$(echo "$STATUS_RESPONSE" | jq -r '.citations // []')

            if [ -n "$OUTPUT_FILE" ]; then
                {
                    echo "# Deep Research Results"
                    echo ""
                    echo "**Query**: $QUERY"
                    echo "**Date**: $(date +%Y-%m-%d)"
                    echo "**Job ID**: $REQUEST_ID"
                    echo ""
                    echo "---"
                    echo ""
                    echo "$CONTENT"
                    echo ""
                    echo "---"
                    echo ""
                    echo "## Citations"
                    echo ""
                    echo "$CITATIONS" | jq -r '.[] | "- [\(.title // "Source")](\(.url))"' 2>/dev/null || echo "No citations available"
                } > "$OUTPUT_FILE"
                echo -e "Results saved to: ${GREEN}$OUTPUT_FILE${NC}"
            else
                echo "$CONTENT"
                echo ""
                echo -e "${BLUE}--- Citations ---${NC}"
                echo "$CITATIONS" | jq -r '.[] | "- \(.title // "Source"): \(.url)"' 2>/dev/null || echo "No citations available"
            fi

            # Show usage stats
            USAGE=$(echo "$STATUS_RESPONSE" | jq -r '.usage // {}')
            if [ "$USAGE" != "{}" ]; then
                echo ""
                echo -e "${BLUE}--- Usage ---${NC}"
                echo "$USAGE" | jq -r '"Prompt tokens: \(.prompt_tokens // 0), Completion tokens: \(.completion_tokens // 0)"'
            fi

            exit 0
            ;;
        "failed")
            echo -e "\n${RED}Research failed${NC}"
            ERROR=$(echo "$STATUS_RESPONSE" | jq -r '.error // "Unknown error"')
            echo "Error: $ERROR"
            exit 1
            ;;
        "processing"|"pending"|"queued")
            DOTS="${DOTS}."
            if [ ${#DOTS} -gt 50 ]; then
                DOTS="."
            fi
            printf "\r${YELLOW}Status: %s [%ds]${NC} %s" "$STATE" "$ELAPSED" "$DOTS"
            sleep $POLL_INTERVAL
            ;;
        *)
            echo -e "\n${YELLOW}Unknown status: $STATE${NC}"
            sleep $POLL_INTERVAL
            ;;
    esac
done
