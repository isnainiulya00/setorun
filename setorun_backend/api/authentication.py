from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.exceptions import InvalidToken

from .models import Guru, Murid
from .tokens import USER_TYPE_GURU, USER_TYPE_MURID


class SetorunJWTAuthentication(JWTAuthentication):
    def get_user(self, validated_token):
        user_type = validated_token.get('user_type')
        user_id = validated_token.get('user_id')

        if not user_type or not user_id:
            raise InvalidToken('Token tidak berisi identitas pengguna.')

        if user_type == USER_TYPE_GURU:
            try:
                return Guru.objects.select_related('halaqoh').get(pk=user_id)
            except Guru.DoesNotExist as exc:
                raise InvalidToken('Akun guru tidak ditemukan.') from exc

        if user_type == USER_TYPE_MURID:
            try:
                return Murid.objects.select_related('halaqoh', 'halaqoh__guru').get(pk=user_id)
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
