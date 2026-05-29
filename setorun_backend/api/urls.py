from django.urls import path

from .views import (
    ChatConversationListView,
    ChatMessageListView,
    ChatSendView,
    GuruMuridListView,
    HalaqohListView,
    LoginView,
    LogoutView,
    MuridHomeView,
    MutabaahDetailView,
    MutabaahListCreateView,
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
    path('home/murid/', MuridHomeView.as_view(), name='home-murid'),
    path('mutabaah/', MutabaahListCreateView.as_view(), name='mutabaah-list'),
    path('mutabaah/<int:pk>/', MutabaahDetailView.as_view(), name='mutabaah-detail'),
    path('murid/', GuruMuridListView.as_view(), name='murid-list'),
    path('chat/conversations/', ChatConversationListView.as_view(), name='chat-conversations'),
    path('chat/messages/', ChatMessageListView.as_view(), name='chat-messages'),
    path('chat/send/', ChatSendView.as_view(), name='chat-send'),
]
