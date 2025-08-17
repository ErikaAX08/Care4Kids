# utils/mongodb.py
import logging

from django.conf import settings
from pymongo import MongoClient

logger = logging.getLogger(__name__)


class MongoDBConnection:
    _instance = None
    _client = None
    _database = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self):
        if self._client is None:
            self.connect()

    def connect(self):
        try:
            # Simple connection since no auth is required
            mongodb_settings = settings.MONGODB_SETTINGS
            connection_string = f"mongodb://{mongodb_settings['host']}:{mongodb_settings['port']}/{mongodb_settings['database']}"

            self._client = MongoClient(connection_string)
            self._database = self._client[mongodb_settings["database"]]

            # Test connection
            self._client.admin.command("ping")
            logger.info(f"Successfully connected to MongoDB test database")

        except Exception as e:
            logger.error(f"Failed to connect to MongoDB: {e}")
            raise

    def get_database(self):
        return self._database

    def get_collection(self, collection_name):
        return self._database[collection_name]

    def close(self):
        if self._client:
            self._client.close()


# Create singleton instance
mongodb_connection = MongoDBConnection()
