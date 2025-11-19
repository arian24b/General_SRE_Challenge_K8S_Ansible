from sqlalchemy import Column, Integer, String

from app.db.database import Base


class IPRecord(Base):
    __tablename__ = "ip_records"

    id = Column(Integer, primary_key=True, index=True)
    ip = Column(String, unique=True, index=True, nullable=False)
    country = Column(String, nullable=False)
