@echo off

call .\gradlew.bat -Dhadoop.home.dir=%~dp0\hadoop.win run --args="%*"
