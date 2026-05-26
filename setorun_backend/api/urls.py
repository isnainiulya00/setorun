from django.urls import path

from .views import (
    HalaqohListView,
    LoginView,
    LogoutView,
    MyHalaqohView,
    ProfileView,
    StudentRegisterView,
)

urlpatterns = [
    path('auth/login/', LoginView.as_view(), name='auth-login'),
    path('auth/register/', StudentRegisterView.as_view(), name='auth-register'),
    path('auth/logout/', LogoutView.as_view(), name='auth-logout'),
    path('auth/profile/', ProfileView.as_view(), name='auth-profile'),
    path('halaqoh/', HalaqohListView.as_view(), name='halaqoh-list'),
    path('halaqoh/me/', MyHalaqohView.as_view(), name='halaqoh-me'),
]
