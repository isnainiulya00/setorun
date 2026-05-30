from rest_framework_simplejwt.tokens import RefreshToken

USER_TYPE_GURU = 'guru'
USER_TYPE_MURID = 'murid'

def get_tokens_for_account(account):
    if account.is_teacher:
        user_type = USER_TYPE_GURU
    else:
        user_type = USER_TYPE_MURID

    refresh = RefreshToken.for_user(account.user)
    
    refresh['user_type'] = user_type
    refresh['profile_id'] = account.pk  
    refresh['email'] = account.user.email
    refresh['nama'] = account.nama

    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }