@echo off
chcp 65001 > NUL
pushd %~dp0

set CURL_CMD=C:\Windows\System32\curl.exe
if not exist %CURL_CMD% (
	echo "CURL not found."
	popd & pause & exit /b 1
)

echo https://github.com/LostRuins/koboldcpp
echo https://huggingface.co/Sdff-Ltba/LightChatAssistant-2x7B-GGUF
echo.
echo "以上の URL からファイルをダウンロードして利用します（URL を Ctrl クリックで開けます）。"
echo "よろしいですか？ [y/n]"
set /p YES_OR_NO=
if /i not "%YES_OR_NO%" == "y" ( popd & exit /b 1 )

if not exist koboldcpp.exe (
	echo %CURL_CMD% -LO https://github.com/LostRuins/koboldcpp/releases/download/v1.61.2/koboldcpp.exe
	%CURL_CMD% -LO https://github.com/LostRuins/koboldcpp/releases/download/v1.61.2/koboldcpp.exe
)
if not exist koboldcpp.exe (
	echo "Failed to download koboldcpp.exe"
	popd & pause & exit /b 1
)

call :MAKE_BAT iq3xxs_imatrix 0
call :MAKE_BAT iq3xxs_imatrix 11
call :MAKE_BAT iq3xxs_imatrix 22
call :MAKE_BAT iq3xxs_imatrix 33
call :MAKE_BAT q4_k_m 0
call :MAKE_BAT q4_k_m 24
call :MAKE_BAT q4_k_m 33
call :MAKE_BAT q6_k 0
call :MAKE_BAT q6_k 20
call :MAKE_BAT q6_k 33
call :MAKE_BAT q8 0
call :MAKE_BAT q8 16
call :MAKE_BAT q8 33

popd
exit /b 0

:MAKE_BAT
set QUANTIZE=%1
set GPU_LAYERS=%2

set MODEL_FILE=LightChatAssistant-2x7B_%QUANTIZE%.gguf
set KOBOLDCPP_ARGS=^
--model %MODEL_FILE% ^
--contextsize 32768 ^
--usecublas ^
--gpulayers %GPU_LAYERS% ^
--launch

set RUN_BAT=EasyLightChatAssistant-%QUANTIZE%_L%GPU_LAYERS%.bat
echo @echo off>%RUN_BAT%
echo if not exist %MODEL_FILE% ( %CURL_CMD% -LO https://huggingface.co/Sdff-Ltba/LightChatAssistant-2x7B-GGUF/resolve/main/%MODEL_FILE% ^)>>%RUN_BAT%
echo koboldcpp.exe %KOBOLDCPP_ARGS%>>%RUN_BAT%

exit /b 0
