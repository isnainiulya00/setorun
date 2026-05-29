from django.contrib import admin

from .models import ChatMessage, ChatRoom, Guru, Halaqoh, Murid, Mutabaah


@admin.register(Guru)
class GuruAdmin(admin.ModelAdmin):
    list_display = ['nama', 'email', 'gender']
    search_fields = ['nama', 'email']


@admin.register(Halaqoh)
class HalaqohAdmin(admin.ModelAdmin):
    list_display = ['nama', 'gender', 'jadwal', 'guru']
    search_fields = ['nama']


@admin.register(Murid)
class MuridAdmin(admin.ModelAdmin):
    list_display = ['nama', 'email', 'gender', 'halaqoh']
    list_filter = ['gender', 'halaqoh']
    search_fields = ['nama', 'email']


@admin.register(Mutabaah)
class MutabaahAdmin(admin.ModelAdmin):
    list_display = ['murid', 'nama_surah', 'ayat', 'note', 'tanggal']
    list_filter = ['note', 'tanggal']
    search_fields = ['murid__nama', 'nama_surah']


@admin.register(ChatRoom)
class ChatRoomAdmin(admin.ModelAdmin):
    list_display = ['murid', 'halaqoh', 'created_at']


@admin.register(ChatMessage)
class ChatMessageAdmin(admin.ModelAdmin):
    list_display = ['room', 'sender_type', 'text', 'created_at']
    list_filter = ['sender_type']
