from sqlalchemy import Column, String, Integer, Boolean, DateTime, ForeignKey, func
from app.database.base import Base
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from app.models.certified_copy_model import CertifiedCopy




class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, index=True)
    email = Column(String, unique=True, nullable=False, index=True)
    password_hash = Column(String, nullable=False)
    role = Column(String, default="user")
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    fcm_token = Column(String, nullable=True)

    # ─────────────────────────────────────────────────────────────
    # OWNERSHIP RELATIONSHIPS
    #
    # Every relationship below represents data that belongs to exactly
    # one user (one lawyer). All of them share the same two settings:
    #
    #   cascade="all, delete-orphan"
    #       Tells SQLAlchemy: if this User is deleted, these child rows
    #       have no reason to exist anymore — delete them too.
    #
    #   passive_deletes=True
    #       Tells SQLAlchemy: don't bother loading every child row into
    #       memory and deleting them one-by-one in Python. Instead,
    #       just delete the User row and trust the database's own
    #       ON DELETE CASCADE foreign key constraint to clean up the
    #       rest. This is faster, and it also means the cleanup still
    #       happens correctly even if a row gets deleted by something
    #       outside this app (raw SQL, an admin panel, etc.) — because
    #       the safety net lives in the database, not just in this code.
    #
    #       IMPORTANT: passive_deletes=True only works because the
    #       matching foreign key in the actual database (checked via
    #       pgAdmin → table → Constraints → *_user_id_fkey → Action tab)
    #       is set to ON DELETE CASCADE. If that FK setting is ever
    #       changed back to NO ACTION, deleting a user will start
    #       failing with a foreign key violation.
    # ─────────────────────────────────────────────────────────────

    # A lawyer's login sessions. Deleted immediately when the account goes.
    refresh_tokens = relationship(
        "RefreshToken",
        back_populates="user",
        cascade="all, delete-orphan",
        passive_deletes=True,
    )

    # Password reset codes tied to this account.
    password_reset_otps = relationship(
        "PasswordResetOTP",
        back_populates="user",
        cascade="all, delete-orphan",
        passive_deletes=True,
    )

    # Certified copies requested by this lawyer.
    # NOTE: CertifiedCopy also has a case_id foreign key pointing at Case —
    # that's a SEPARATE relationship, declared on the Case model, using its
    # own case_id cascade. This one only governs the user_id side: it fires
    # when the USER is deleted, not when a single case is deleted.
    certified_copies = relationship(
        "CertifiedCopy",
        back_populates="user",
        cascade="all, delete-orphan",
        passive_deletes=True,
    )

    # Legal tasks assigned to this lawyer.
    # Same note as above — LegalTask also has a case_id relationship declared
    # separately on Case. Two owners, two independent cascade paths.
    legal_tasks = relationship(
        "LegalTask",
        back_populates="user",
        cascade="all, delete-orphan",
        passive_deletes=True,
    )

    # All cases filed by this lawyer.
    # Deleting a User cascades here, and deleting a Case here in turn
    # cascades to that case's own hearings, files, and related clients
    # (via case_id foreign keys defined on the Case model) — so deleting
    # a user cleans out the entire tree, not just the top-level rows.
    #
    # backref="owner" auto-creates the reverse side (Case.owner) without
    # needing to add anything to the Case model itself.
    cases = relationship(
        "Case",
        backref="owner",
        cascade="all, delete-orphan",
        passive_deletes=True,
    )

    # All clients added by this lawyer.
    clients = relationship(
        "Client",
        backref="owner",
        cascade="all, delete-orphan",
        passive_deletes=True,
    )


class RefreshToken(Base):
    __tablename__ = "refresh_tokens"

    id= Column(String, primary_key=True, default=lambda:str(uuid.uuid4()))
    user_id= Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE",))
    token_hash= Column(String(128), unique=True, nullable=False,  index=True)
    revoked= Column(Boolean, default=False)
    expire_at= Column(DateTime(timezone=True), nullable=False)
    created_at= Column(DateTime(timezone=True), server_default=func.now())

    user= relationship("User", back_populates="refresh_tokens")


class PasswordResetOTP(Base):
    """
    Stores hashed OTP codes for the forgot-password flow.
    One user can have multiple rows over time, but only one should ever be
    active (is_used=False) at once -- the service layer enforces this by
    invalidating old rows whenever a new OTP is requested.
    """
    __tablename__ = "password_reset_otps"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    otp_hash = Column(String(64), nullable=False)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    attempts = Column(Integer, default=0, nullable=False)
    is_used = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)

    user = relationship("User", back_populates="password_reset_otps")