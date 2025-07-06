"""
FastAPI Testing Template

This template provides comprehensive examples for testing FastAPI applications.
Includes async testing, database integration, authentication, and more.
"""

import pytest
from fastapi.testclient import TestClient
from httpx import AsyncClient
import asyncio
from typing import AsyncGenerator, Generator

# Import your FastAPI app and dependencies
# from main import app
# from database import get_db, Base, engine
# from auth import get_current_user
# from models import User, Item

# Mock app for template - replace with your actual app
from fastapi import FastAPI, Depends, HTTPException, status
from pydantic import BaseModel

app = FastAPI()

class ItemCreate(BaseModel):
    title: str
    description: str

class Item(BaseModel):
    id: int
    title: str
    description: str
    owner_id: int

@app.get("/")
async def read_root():
    return {"message": "Hello World"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.post("/items/", response_model=Item)
async def create_item(item: ItemCreate):
    return Item(id=1, title=item.title, description=item.description, owner_id=1)

# Test Fixtures
@pytest.fixture
def client() -> Generator[TestClient, None, None]:
    """
    Synchronous test client for FastAPI app.
    Use for simple tests that don't need async functionality.
    """
    with TestClient(app) as test_client:
        yield test_client

@pytest.fixture
async def async_client() -> AsyncGenerator[AsyncClient, None]:
    """
    Asynchronous test client for FastAPI app.
    Use for testing async endpoints and complex scenarios.
    """
    async with AsyncClient(app=app, base_url="http://test") as test_client:
        yield test_client

@pytest.fixture
def db_session():
    """
    Database session fixture for testing.
    Creates a test database and cleans up after each test.
    """
    # Example with SQLAlchemy
    # from sqlalchemy import create_engine
    # from sqlalchemy.orm import sessionmaker
    
    # SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
    # engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
    # TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    
    # Base.metadata.create_all(bind=engine)
    # db = TestingSessionLocal()
    
    # try:
    #     yield db
    # finally:
    #     db.close()
    #     Base.metadata.drop_all(bind=engine)
    
    # Mock database session for template
    yield {}

@pytest.fixture
def test_user():
    """
    Test user fixture.
    """
    return {
        "id": 1,
        "email": "test@example.com",
        "username": "testuser",
        "is_active": True
    }

@pytest.fixture
def auth_headers(test_user):
    """
    Authentication headers for authorized requests.
    """
    # In real app, generate actual JWT token
    token = "fake-jwt-token"
    return {"Authorization": f"Bearer {token}"}

# Basic API Tests
class TestBasicEndpoints:
    """Test basic API functionality."""
    
    def test_read_root(self, client: TestClient):
        """Test the root endpoint."""
        response = client.get("/")
        assert response.status_code == 200
        assert response.json() == {"message": "Hello World"}
    
    def test_health_check(self, client: TestClient):
        """Test health check endpoint."""
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json() == {"status": "healthy"}
    
    def test_nonexistent_endpoint(self, client: TestClient):
        """Test 404 for non-existent endpoints."""
        response = client.get("/nonexistent")
        assert response.status_code == 404

# Async API Tests
class TestAsyncEndpoints:
    """Test async API functionality."""
    
    @pytest.mark.asyncio
    async def test_async_root(self, async_client: AsyncClient):
        """Test root endpoint with async client."""
        response = await async_client.get("/")
        assert response.status_code == 200
        assert response.json() == {"message": "Hello World"}
    
    @pytest.mark.asyncio
    async def test_concurrent_requests(self, async_client: AsyncClient):
        """Test handling multiple concurrent requests."""
        tasks = [async_client.get("/health") for _ in range(10)]
        responses = await asyncio.gather(*tasks)
        
        for response in responses:
            assert response.status_code == 200
            assert response.json() == {"status": "healthy"}

# CRUD Operations Tests
class TestCRUDOperations:
    """Test CRUD operations."""
    
    def test_create_item(self, client: TestClient):
        """Test creating a new item."""
        item_data = {
            "title": "Test Item",
            "description": "This is a test item"
        }
        
        response = client.post("/items/", json=item_data)
        assert response.status_code == 200
        
        data = response.json()
        assert data["title"] == item_data["title"]
        assert data["description"] == item_data["description"]
        assert "id" in data
    
    def test_create_item_validation(self, client: TestClient):
        """Test item creation with invalid data."""
        # Missing required fields
        response = client.post("/items/", json={})
        assert response.status_code == 422
        
        # Invalid data types
        response = client.post("/items/", json={
            "title": 123,  # Should be string
            "description": "Valid description"
        })
        assert response.status_code == 422
    
    @pytest.mark.asyncio
    async def test_item_lifecycle(self, async_client: AsyncClient):
        """Test complete item lifecycle: create, read, update, delete."""
        # Create item
        item_data = {
            "title": "Lifecycle Test Item",
            "description": "Testing full lifecycle"
        }
        
        create_response = await async_client.post("/items/", json=item_data)
        assert create_response.status_code == 200
        
        item = create_response.json()
        item_id = item["id"]
        
        # Read item (would need GET /items/{id} endpoint)
        # read_response = await async_client.get(f"/items/{item_id}")
        # assert read_response.status_code == 200
        
        # Update item (would need PUT /items/{id} endpoint)
        # update_data = {"title": "Updated Title", "description": "Updated description"}
        # update_response = await async_client.put(f"/items/{item_id}", json=update_data)
        # assert update_response.status_code == 200
        
        # Delete item (would need DELETE /items/{id} endpoint)
        # delete_response = await async_client.delete(f"/items/{item_id}")
        # assert delete_response.status_code == 204

# Authentication Tests
class TestAuthentication:
    """Test authentication and authorization."""
    
    def test_protected_endpoint_without_auth(self, client: TestClient):
        """Test accessing protected endpoint without authentication."""
        # This would test a protected endpoint
        # response = client.get("/protected")
        # assert response.status_code == 401
        pass
    
    def test_protected_endpoint_with_auth(self, client: TestClient, auth_headers):
        """Test accessing protected endpoint with valid authentication."""
        # response = client.get("/protected", headers=auth_headers)
        # assert response.status_code == 200
        pass
    
    def test_invalid_token(self, client: TestClient):
        """Test invalid authentication token."""
        headers = {"Authorization": "Bearer invalid-token"}
        # response = client.get("/protected", headers=headers)
        # assert response.status_code == 401
        pass
    
    def test_expired_token(self, client: TestClient):
        """Test expired authentication token."""
        # You would generate an expired token here
        # headers = {"Authorization": f"Bearer {expired_token}"}
        # response = client.get("/protected", headers=headers)
        # assert response.status_code == 401
        pass

# Database Integration Tests
class TestDatabaseIntegration:
    """Test database operations."""
    
    def test_database_connection(self, db_session):
        """Test database connection."""
        # Test that database session is working
        assert db_session is not None
    
    @pytest.mark.asyncio
    async def test_database_transaction_rollback(self, async_client: AsyncClient, db_session):
        """Test database transaction rollback on error."""
        # This would test that database transactions are properly rolled back
        # when an error occurs during request processing
        pass
    
    def test_database_constraints(self, client: TestClient, db_session):
        """Test database constraints are enforced."""
        # Test unique constraints, foreign key constraints, etc.
        pass

# Error Handling Tests
class TestErrorHandling:
    """Test error handling scenarios."""
    
    def test_validation_errors(self, client: TestClient):
        """Test validation error responses."""
        response = client.post("/items/", json={"invalid": "data"})
        assert response.status_code == 422
        
        error_data = response.json()
        assert "detail" in error_data
        assert isinstance(error_data["detail"], list)
    
    def test_internal_server_error(self, client: TestClient):
        """Test internal server error handling."""
        # This would test a scenario that causes a 500 error
        # You might need to mock a dependency to raise an exception
        pass
    
    def test_custom_exception_handler(self, client: TestClient):
        """Test custom exception handlers."""
        # Test that custom exceptions are properly handled
        # and return appropriate error responses
        pass

# Performance Tests
class TestPerformance:
    """Test API performance."""
    
    @pytest.mark.benchmark
    def test_endpoint_performance(self, client: TestClient, benchmark):
        """Benchmark endpoint performance."""
        def make_request():
            return client.get("/")
        
        result = benchmark(make_request)
        assert result.status_code == 200
    
    @pytest.mark.asyncio
    async def test_concurrent_requests_performance(self, async_client: AsyncClient):
        """Test performance under concurrent load."""
        import time
        
        start_time = time.time()
        tasks = [async_client.get("/health") for _ in range(100)]
        responses = await asyncio.gather(*tasks)
        end_time = time.time()
        
        # All requests should succeed
        for response in responses:
            assert response.status_code == 200
        
        # Should complete within reasonable time
        assert end_time - start_time < 5.0  # Adjust threshold as needed

# Integration Tests
class TestIntegration:
    """Test integration scenarios."""
    
    @pytest.mark.integration
    @pytest.mark.asyncio
    async def test_complete_user_workflow(self, async_client: AsyncClient):
        """Test complete user workflow end-to-end."""
        # 1. Register user
        # 2. Login
        # 3. Create items
        # 4. List items
        # 5. Update item
        # 6. Delete item
        # 7. Logout
        pass
    
    @pytest.mark.integration
    def test_external_api_integration(self, client: TestClient):
        """Test integration with external APIs."""
        # Test endpoints that call external services
        # Use mocking for external dependencies in unit tests
        pass

# Test Utilities
def create_test_item(client: TestClient, **kwargs):
    """Utility function to create test items."""
    default_data = {
        "title": "Test Item",
        "description": "Test Description"
    }
    default_data.update(kwargs)
    
    response = client.post("/items/", json=default_data)
    assert response.status_code == 200
    return response.json()

def authenticate_user(client: TestClient, user_data):
    """Utility function to authenticate a user and return auth headers."""
    # This would handle user login and return auth headers
    # response = client.post("/auth/login", json=user_data)
    # token = response.json()["access_token"]
    # return {"Authorization": f"Bearer {token}"}
    return {"Authorization": "Bearer fake-token"}

# Parametrized Tests
@pytest.mark.parametrize("title,description,expected_status", [
    ("Valid Title", "Valid Description", 200),
    ("", "Valid Description", 422),  # Empty title
    ("Valid Title", "", 422),  # Empty description
    ("A" * 1000, "Valid Description", 422),  # Title too long
])
def test_item_creation_validation(client: TestClient, title, description, expected_status):
    """Test item creation with various input combinations."""
    response = client.post("/items/", json={
        "title": title,
        "description": description
    })
    assert response.status_code == expected_status

# Cleanup and Setup
@pytest.fixture(autouse=True)
def cleanup_after_test():
    """Cleanup after each test."""
    yield
    # Cleanup code here (clear cache, reset state, etc.)

def pytest_configure(config):
    """Configure pytest with custom markers."""
    config.addinivalue_line(
        "markers", "integration: mark test as integration test"
    )
    config.addinivalue_line(
        "markers", "benchmark: mark test as benchmark test"
    )
    config.addinivalue_line(
        "markers", "slow: mark test as slow running"
    )