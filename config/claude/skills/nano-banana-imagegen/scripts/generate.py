#!/usr/bin/env python3
"""
Nano Banana Image Generator
Generate images using Google's Gemini via direct API or OpenRouter.

Usage:
    python generate.py "your prompt" [options]

Options:
    --resolution 2K       Resolution: 1K, 2K, or 4K (default: 2K)
    --style minimalist    Style preset (default: minimalist)
    --output ./img.png    Output path (default: auto-generated)
    --count 1             Number of variations (1-4, default: 1)
    --model flash         Model: flash or pro (default: flash)
    --provider openrouter Provider: openrouter or google (default: openrouter)

Environment Variables:
    OPENROUTER_API_KEY  - For OpenRouter (preferred)
    GOOGLE_API_KEY      - For direct Google API
"""

import argparse
import base64
import json
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional, Tuple


def get_api_config() -> Tuple[str, str]:
    """
    Get API key and provider from environment.
    Returns: (api_key, provider)
    Prefers OpenRouter if available.
    """
    # Check OpenRouter first (preferred)
    openrouter_key = os.getenv("OPENROUTER_API_KEY")
    if openrouter_key:
        return openrouter_key, "openrouter"

    # Fall back to Google API
    google_key = os.getenv("GOOGLE_API_KEY")
    if google_key:
        return google_key, "google"

    # Try config file
    config_path = Path.home() / ".config" / "nano-banana" / "config.json"
    if config_path.exists():
        with open(config_path) as f:
            config = json.load(f)
            provider = config.get("provider", "openrouter")
            if provider == "openrouter":
                key = os.getenv(config.get("api_key_env", "OPENROUTER_API_KEY"))
            else:
                key = os.getenv(config.get("api_key_env", "GOOGLE_API_KEY"))
            if key:
                return key, provider

    print("Error: No API key found")
    print("Set one of:")
    print("  export OPENROUTER_API_KEY='your-key'  (preferred)")
    print("  export GOOGLE_API_KEY='your-key'")
    sys.exit(1)


def generate_via_cli(prompt: str, output_path: str) -> bool:
    """
    Generate image using Gemini CLI (simplest approach).
    Requires: gemini CLI installed and configured.
    """
    enhanced_prompt = f"Generate an image: {prompt}. Output as a high-quality PNG image."

    try:
        result = subprocess.run(
            ["gemini", "-p", enhanced_prompt, "--output", output_path],
            capture_output=True,
            text=True,
            timeout=120
        )

        if result.returncode == 0:
            print(f"Generated: {output_path}")
            return True
        else:
            print(f"CLI Error: {result.stderr}")
            return False

    except FileNotFoundError:
        print("Gemini CLI not found. Install with: pip install google-generativeai")
        return False
    except subprocess.TimeoutExpired:
        print("Generation timed out (>120s)")
        return False


def generate_via_openrouter(
    prompt: str,
    api_key: str,
    resolution: str = "2K",
    style: str = "minimalist",
    model: str = "flash",
    output_path: Optional[str] = None
) -> dict:
    """
    Generate image using OpenRouter API.
    OpenRouter provides unified access to Gemini models.
    """
    try:
        import httpx
    except ImportError:
        print("httpx not installed. Run: uv add httpx")
        return {"success": False, "error": "httpx not installed"}

    # OpenRouter model mapping for Gemini image-capable models
    model_map = {
        "flash": "google/gemini-2.0-flash-exp:free",  # Free tier, text only
        "pro": "google/gemini-3-pro-image-preview",   # Nano Banana Pro - IMAGE GENERATION
        "nano-banana": "google/gemini-3-pro-image-preview",  # Alias for pro
        "flash-thinking": "google/gemini-2.0-flash-thinking-exp:free",
    }
    model_id = model_map.get(model, model_map["pro"])  # Default to pro for image gen

    # Style presets
    style_map = {
        "minimalist": "Minimalist, flat design, clean lines, high contrast",
        "realistic": "Photorealistic, cinematic, high detail",
        "illustration": "Digital illustration, artistic, stylized",
        "technical": "Technical diagram, blueprint style, precise",
    }
    style_text = style_map.get(style, "")

    # Build enhanced prompt
    enhanced_prompt = f"Generate an image: {prompt}"
    if style_text:
        enhanced_prompt += f"\n\nStyle: {style_text}"

    # Resolution hints
    res_hints = {
        "1K": "1024x1024 resolution",
        "2K": "2048x2048 resolution, high quality",
        "4K": "4096x4096 resolution, ultra high quality",
    }
    if resolution in res_hints:
        enhanced_prompt += f"\n\nQuality: {res_hints[resolution]}"

    # OpenRouter API request
    endpoint = "https://openrouter.ai/api/v1/chat/completions"

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
        "HTTP-Referer": "https://github.com/user/nano-banana-imagegen",
        "X-Title": "Nano Banana Image Generator",
    }

    # Aspect ratio mapping
    aspect_ratios = {
        "1K": "1:1",
        "2K": "1:1",
        "4K": "1:1",
    }

    payload = {
        "model": model_id,
        "messages": [
            {
                "role": "user",
                "content": enhanced_prompt
            }
        ],
        "modalities": ["image", "text"],  # Required for image generation
        "temperature": 1.0,
        "max_tokens": 8192,
    }

    try:
        print(f"Using OpenRouter with model: {model_id}")
        response = httpx.post(
            endpoint,
            json=payload,
            headers=headers,
            timeout=120.0
        )
        response.raise_for_status()
        result = response.json()

        # Debug: print full response structure
        print(f"Response keys: {result.keys()}")

        # Check response for image data
        if "choices" in result and result["choices"]:
            choice = result["choices"][0]
            message = choice.get("message", {})

            # Check for images field (OpenRouter image generation format)
            images = message.get("images", [])
            if images:
                print(f"Found {len(images)} image(s) in response")
                # Take the first image - handle nested structure: images[].image_url.url
                first_image = images[0]
                if isinstance(first_image, str):
                    image_url = first_image
                elif isinstance(first_image, dict):
                    # Check for nested image_url.url structure (OpenRouter format)
                    if "image_url" in first_image:
                        image_url = first_image.get("image_url", {}).get("url", "")
                    else:
                        image_url = first_image.get("url", "")
                else:
                    image_url = ""

                if image_url and image_url.startswith("data:image"):
                    # Base64 data URL
                    try:
                        b64_data = image_url.split("base64,")[1]
                        image_bytes = base64.b64decode(b64_data)

                        if not output_path:
                            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                            output_path = f"generated_{timestamp}.png"

                        Path(output_path).write_bytes(image_bytes)
                        print(f"Generated: {output_path}")

                        return {
                            "success": True,
                            "output_path": output_path,
                            "size_bytes": len(image_bytes),
                            "provider": "openrouter",
                        }
                    except Exception as e:
                        print(f"Error decoding image: {e}")

            # Check content for inline base64 image data
            content = message.get("content", "")

            # Handle content as list (multimodal response)
            if isinstance(content, list):
                for part in content:
                    if isinstance(part, dict):
                        if part.get("type") == "image_url":
                            image_url = part.get("image_url", {}).get("url", "")
                            if image_url.startswith("data:image"):
                                try:
                                    b64_data = image_url.split("base64,")[1]
                                    image_bytes = base64.b64decode(b64_data)

                                    if not output_path:
                                        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                                        output_path = f"generated_{timestamp}.png"

                                    Path(output_path).write_bytes(image_bytes)
                                    print(f"Generated: {output_path}")

                                    return {
                                        "success": True,
                                        "output_path": output_path,
                                        "size_bytes": len(image_bytes),
                                        "provider": "openrouter",
                                    }
                                except Exception as e:
                                    print(f"Error decoding image: {e}")
                content = str(content)  # Convert to string for further processing

            # Check if content contains base64 image data
            if isinstance(content, str):
                if "data:image" in content:
                    try:
                        # Extract base64 from data URL
                        import re
                        match = re.search(r'data:image/[^;]+;base64,([A-Za-z0-9+/=]+)', content)
                        if match:
                            b64_data = match.group(1)
                            image_bytes = base64.b64decode(b64_data)

                            if not output_path:
                                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                                output_path = f"generated_{timestamp}.png"

                            Path(output_path).write_bytes(image_bytes)
                            print(f"Generated: {output_path}")

                            return {
                                "success": True,
                                "output_path": output_path,
                                "size_bytes": len(image_bytes),
                                "provider": "openrouter",
                            }
                    except Exception as e:
                        print(f"Error extracting image: {e}")

                # Check for raw base64 (PNG or JPEG magic bytes in base64)
                if content.startswith("iVBOR") or content.startswith("/9j/"):
                    try:
                        image_bytes = base64.b64decode(content.strip())

                        if not output_path:
                            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                            output_path = f"generated_{timestamp}.png"

                        Path(output_path).write_bytes(image_bytes)
                        print(f"Generated: {output_path}")

                        return {
                            "success": True,
                            "output_path": output_path,
                            "size_bytes": len(image_bytes),
                            "provider": "openrouter",
                        }
                    except Exception as e:
                        print(f"Error decoding raw base64: {e}")

            # Model returned text only
            content_str = content if isinstance(content, str) else str(content)
            if content_str:
                print(f"Model response (text): {content_str[:500]}...")

            # Save the response for debugging
            if not output_path:
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                output_path = f"prompt_{timestamp}.txt"

            debug_output = f"Original prompt: {prompt}\n\nFull response:\n{json.dumps(result, indent=2)}"
            Path(output_path).write_text(debug_output)
            print(f"Saved debug response to: {output_path}")

            return {
                "success": False,
                "output_path": output_path,
                "type": "text_response",
                "content": content_str,
                "note": "Model did not return image. Check debug output.",
            }

        return {"success": False, "error": "No response from model", "raw": result}

    except httpx.HTTPStatusError as e:
        error_body = e.response.text if hasattr(e.response, 'text') else str(e)
        return {"success": False, "error": f"API error {e.response.status_code}: {error_body}"}
    except Exception as e:
        return {"success": False, "error": str(e)}


def generate_via_google(
    prompt: str,
    api_key: str,
    resolution: str = "2K",
    style: str = "minimalist",
    model: str = "flash",
    output_path: Optional[str] = None
) -> dict:
    """
    Generate image using Google Gemini API directly.
    """
    try:
        import httpx
    except ImportError:
        print("httpx not installed. Run: uv add httpx")
        return {"success": False, "error": "httpx not installed"}

    # Model selection
    model_map = {
        "flash": "gemini-2.0-flash-exp",
        "pro": "gemini-1.5-pro",
    }
    model_id = model_map.get(model, model_map["flash"])

    # Style presets
    style_map = {
        "minimalist": "Minimalist, flat design, clean lines, high contrast",
        "realistic": "Photorealistic, cinematic, high detail",
        "illustration": "Digital illustration, artistic, stylized",
        "technical": "Technical diagram, blueprint style, precise",
    }
    style_text = style_map.get(style, "")

    # Build enhanced prompt
    enhanced_prompt = f"Generate an image: {prompt}"
    if style_text:
        enhanced_prompt += f"\n\nStyle: {style_text}"

    res_hints = {
        "1K": "1024x1024 resolution",
        "2K": "2048x2048 resolution, high quality",
        "4K": "4096x4096 resolution, ultra high quality",
    }
    if resolution in res_hints:
        enhanced_prompt += f"\n\nQuality: {res_hints[resolution]}"

    # Google API request
    endpoint = f"https://generativelanguage.googleapis.com/v1beta/models/{model_id}:generateContent"

    headers = {
        "Content-Type": "application/json",
        "x-goog-api-key": api_key,
    }

    payload = {
        "contents": [{
            "parts": [{
                "text": enhanced_prompt
            }]
        }],
        "generationConfig": {
            "temperature": 1.0,
            "topP": 0.95,
            "topK": 64,
            "maxOutputTokens": 8192,
        }
    }

    try:
        print(f"Using Google API with model: {model_id}")
        response = httpx.post(
            endpoint,
            json=payload,
            headers=headers,
            timeout=120.0
        )
        response.raise_for_status()
        result = response.json()

        if "candidates" in result:
            candidate = result["candidates"][0]
            content = candidate.get("content", {})
            parts = content.get("parts", [])

            for part in parts:
                if "inlineData" in part:
                    image_data = part["inlineData"]
                    mime_type = image_data.get("mimeType", "image/png")
                    data = base64.b64decode(image_data["data"])

                    if not output_path:
                        ext = "png" if "png" in mime_type else "jpg"
                        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                        output_path = f"generated_{timestamp}.{ext}"

                    Path(output_path).write_bytes(data)
                    print(f"Generated: {output_path}")

                    return {
                        "success": True,
                        "output_path": output_path,
                        "mime_type": mime_type,
                        "size_bytes": len(data),
                        "provider": "google",
                    }

                elif "text" in part:
                    text = part["text"]
                    print(f"Model response: {text[:200]}...")
                    return {
                        "success": False,
                        "error": "Model returned text instead of image",
                        "text": text,
                    }

        return {"success": False, "error": "No image data in response", "raw": result}

    except httpx.HTTPStatusError as e:
        return {"success": False, "error": f"API error: {e.response.status_code}"}
    except Exception as e:
        return {"success": False, "error": str(e)}


def main():
    parser = argparse.ArgumentParser(
        description="Generate images using Gemini (via OpenRouter or Google API)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python generate.py "minimalist search icon, 24x24"
  python generate.py "dark mode toggle" --style minimalist --resolution 2K
  python generate.py "tech background" --count 3 --provider openrouter

Environment:
  OPENROUTER_API_KEY  - Use OpenRouter (preferred, free tier available)
  GOOGLE_API_KEY      - Use Google API directly
        """
    )

    parser.add_argument("prompt", help="Image description prompt")
    parser.add_argument("--resolution", default="2K", choices=["1K", "2K", "4K"],
                        help="Output resolution (default: 2K)")
    parser.add_argument("--style", default="minimalist",
                        choices=["minimalist", "realistic", "illustration", "technical"],
                        help="Style preset (default: minimalist)")
    parser.add_argument("--output", "-o", help="Output file path")
    parser.add_argument("--count", "-n", type=int, default=1, choices=[1, 2, 3, 4],
                        help="Number of variations (default: 1)")
    parser.add_argument("--model", default="flash", choices=["flash", "pro", "flash-thinking"],
                        help="Model: flash (fast) or pro (quality)")
    parser.add_argument("--provider", choices=["openrouter", "google", "cli"],
                        help="API provider (default: auto-detect from env)")

    args = parser.parse_args()

    # Determine provider
    if args.provider == "cli":
        output = args.output or f"generated_{datetime.now().strftime('%Y%m%d_%H%M%S')}.png"
        success = generate_via_cli(args.prompt, output)
        sys.exit(0 if success else 1)

    # Get API config
    api_key, detected_provider = get_api_config()
    provider = args.provider or detected_provider

    print(f"Provider: {provider}")

    for i in range(args.count):
        output_path = args.output
        if args.count > 1:
            if output_path:
                base, ext = os.path.splitext(output_path)
                output_path = f"{base}_{i+1}{ext or '.png'}"
            else:
                output_path = None

        if provider == "openrouter":
            result = generate_via_openrouter(
                prompt=args.prompt,
                api_key=api_key,
                resolution=args.resolution,
                style=args.style,
                model=args.model,
                output_path=output_path,
            )
        else:
            result = generate_via_google(
                prompt=args.prompt,
                api_key=api_key,
                resolution=args.resolution,
                style=args.style,
                model=args.model,
                output_path=output_path,
            )

        if not result["success"]:
            print(f"Error: {result.get('error', 'Unknown error')}")
            if i == 0:
                sys.exit(1)

        print(f"[{i+1}/{args.count}] Done")


if __name__ == "__main__":
    main()
