from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy import BigInteger, String, SmallInteger
from .base import Base

#0: active, 1: suspended, 2: deleted
MEMBER_STATE_ACTIVE = 0
MEMBER_STATE_SUSPENDED = 1
MEMBER_STATE_DELETED = 2

# Models
class Member(Base):
    __tablename__ = 'member'
    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    member_name: Mapped[str] = mapped_column(String(255), nullable=False, unique=True)
    state: Mapped[int] = mapped_column(SmallInteger, default=MEMBER_STATE_ACTIVE, nullable=False)
    def __repr__(self) -> str:
        return f"Member(id={self.id}, member_name={self.member_name}, state={self.state})"
