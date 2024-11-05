import datetime
from typing import Optional

from sqlalchemy import (
    BigInteger,
    Boolean,
    CheckConstraint,
    DateTime,
    ForeignKey,
    SmallInteger,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base
from .member import Member
from .message import Message

MESSAGE_DIRECTION_SENT = 0
MESSAGE_DIRECTION_RECEIVED = 1


class MessageBox(Base):
    __tablename__ = "message_box"
    __table_args__ = (
        CheckConstraint(
            f"message_direction IN ({MESSAGE_DIRECTION_SENT}, {MESSAGE_DIRECTION_RECEIVED})",
            name="message_direction_check",
        ),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    message_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("message.id", ondelete="CASCADE"), nullable=False
    )
    member_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("member.id", ondelete="CASCADE"), nullable=False
    )
    is_deleted: Mapped[bool] = mapped_column(
        Boolean, nullable=False, server_default="false"
    )
    message_direction: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    state: Mapped[Optional[bool]] = mapped_column(
        Boolean, nullable=True, server_default="false"
    )  # column to denote if the message is read
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime, nullable=False)

    # Relationships
    message: Mapped["Message"] = relationship("Message")
    member: Mapped["Member"] = relationship("Member")

    def __repr__(self) -> str:
        return f"MessageBox(id={self.id}, member_id={self.member_id}, message_id={self.message_id})"
