from django.db.models import Q

from .models import ChatRoom, Guru, Halaqoh, Murid


def find_account_by_login(login_value):
    """Cari akun guru/murid berdasarkan email atau nama."""
    login = login_value.strip()
    if not login:
        return None

    account = Guru.objects.select_related('halaqoh').filter(
        Q(email__iexact=login) | Q(nama__iexact=login)
    ).first()
    if account:
        return account

    return Murid.objects.select_related('halaqoh', 'halaqoh__guru').filter(
        Q(email__iexact=login) | Q(nama__iexact=login)
    ).first()


def get_or_create_chat_room(murid):
    if not murid.halaqoh_id:
        return None
    room, _ = ChatRoom.objects.get_or_create(
        murid=murid,
        defaults={'halaqoh_id': murid.halaqoh_id},
    )
    return room


def get_guru_halaqoh(guru):
    try:
        return guru.halaqoh
    except Halaqoh.DoesNotExist:
        return None
