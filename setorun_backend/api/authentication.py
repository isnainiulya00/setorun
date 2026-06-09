from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.exceptions import InvalidToken

from .models import Guru, Murid
from .tokens import USER_TYPE_GURU, USER_TYPE_MURID


def get_user_profile(user):
    if isinstance(user, Guru):
        return user
    if isinstance(user, Murid):
        return user
    if hasattr(user, 'guru_profile'):
        return user.guru_profile
    if hasattr(user, 'murid_profile'):
        return user.murid_profile
    return None


class SetorunJWTAuthentication(JWTAuthentication):
    def get_user(self, validated_token):
        user_type = validated_token.get('user_type')
        profile_id = validated_token.get('profile_id')

        if not user_type or profile_id is None:
            raise InvalidToken('Token tidak berisi identitas pengguna.')

        if user_type == USER_TYPE_GURU:
            try:
                return Guru.objects.select_related('user').get(pk=profile_id)
            except Guru.DoesNotExist as exc:
                raise InvalidToken('Akun guru tidak ditemukan.') from exc

        if user_type == USER_TYPE_MURID:
            try:
                return Murid.objects.select_related('halaqoh', 'halaqoh__guru').get(pk=profile_id)
            except Murid.DoesNotExist as exc:
                raise InvalidToken('Akun murid tidak ditemukan.') from exc

        raise InvalidToken('Tipe pengguna tidak valid.')

    def authenticate(self, request):
        result = super().authenticate(request)
        if result is None:
            return None
        user, token = result
        return user, token


def get_account_role(account):
    if isinstance(account, Guru):
        return 'teacher'
    if isinstance(account, Murid):
        return 'student'
    return None
