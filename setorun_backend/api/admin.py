from django.contrib import admin

from .models import Guru, Halaqoh, Murid, Mutabaah


@admin.register(Guru)
class GuruAdmin(admin.ModelAdmin):
    list_display = ['nama', 'email', 'gender']
    search_fields = ['nama', 'email']


@admin.register(Halaqoh)
class HalaqohAdmin(admin.ModelAdmin):
    list_display = ['nama', 'gender', 'guru']
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
