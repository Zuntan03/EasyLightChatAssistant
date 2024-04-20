@echo off
chcp 65001 > NUL
pushd %~dp0

set CURL_CMD=C:\Windows\System32\curl.exe
if not exist %CURL_CMD% (
	echo "CURL not found."
	popd & pause & exit /b 1
)

setlocal enabledelayedexpansion
if not exist koboldcpp.exe (
	echo https://github.com/LostRuins/koboldcpp
	echo https://huggingface.co/Sdff-Ltba/LightChatAssistant-2x7B-GGUF
	echo https://huggingface.co/Aratako/LightChatAssistant-4x7B-GGUF
	echo https://huggingface.co/Aratako/LightChatAssistant-2x7B-optimized-experimental-GGUF
	echo.
	echo "以上の URL からファイルをダウンロードして利用します（URL を Ctrl クリックで開けます）。"
	echo "よろしいですか？ [y/n]"
	set /p YES_OR_NO=
	if /i not "!YES_OR_NO!" == "y" ( popd & exit /b 1 )

	echo %CURL_CMD% -LO https://github.com/LostRuins/koboldcpp/releases/latest/download/koboldcpp.exe --ssl-no-revoke
	%CURL_CMD% -LO https://github.com/LostRuins/koboldcpp/releases/latest/download/koboldcpp.exe --ssl-no-revoke
)
endlocal
if not exist koboldcpp.exe (
	echo "Failed to download koboldcpp.exe"
	popd & pause & exit /b 1
)

call :MAKE_BAT Sdff-Ltba/LightChatAssistant-2x7B-GGUF 2x7B_iq3xxs_imatrix 0
call :MAKE_BAT Sdff-Ltba/LightChatAssistant-2x7B-GGUF 2x7B_iq3xxs_imatrix 11
call :MAKE_BAT Sdff-Ltba/LightChatAssistant-2x7B-GGUF 2x7B_iq3xxs_imatrix 22
call :MAKE_BAT Sdff-Ltba/LightChatAssistant-2x7B-GGUF 2x7B_iq3xxs_imatrix 33
call :MAKE_BAT Sdff-Ltba/LightChatAssistant-2x7B-GGUF 2x7B_iq4xs_imatrix 0
call :MAKE_BAT Sdff-Ltba/LightChatAssistant-2x7B-GGUF 2x7B_iq4xs_imatrix 25
call :MAKE_BAT Sdff-Ltba/LightChatAssistant-2x7B-GGUF 2x7B_iq4xs_imatrix 33
call :MAKE_BAT Sdff-Ltba/LightChatAssistant-2x7B-GGUF 2x7B_q4_k_m 0
call :MAKE_BAT Sdff-Ltba/LightChatAssistant-2x7B-GGUF 2x7B_q4_k_m 24
call :MAKE_BAT Sdff-Ltba/LightChatAssistant-2x7B-GGUF 2x7B_q4_k_m 33
call :MAKE_BAT Sdff-Ltba/LightChatAssistant-2x7B-GGUF 2x7B_q6_k 0
call :MAKE_BAT Sdff-Ltba/LightChatAssistant-2x7B-GGUF 2x7B_q6_k 20
call :MAKE_BAT Sdff-Ltba/LightChatAssistant-2x7B-GGUF 2x7B_q6_k 33
call :MAKE_BAT Sdff-Ltba/LightChatAssistant-2x7B-GGUF 2x7B_q8 0
call :MAKE_BAT Sdff-Ltba/LightChatAssistant-2x7B-GGUF 2x7B_q8 16
call :MAKE_BAT Sdff-Ltba/LightChatAssistant-2x7B-GGUF 2x7B_q8 33

call :MAKE_BAT Aratako/LightChatAssistant-4x7B-GGUF 4x7B_IQ4_XS 0
call :MAKE_BAT Aratako/LightChatAssistant-4x7B-GGUF 4x7B_IQ4_XS 16
call :MAKE_BAT Aratako/LightChatAssistant-4x7B-GGUF 4x7B_IQ4_XS 33
call :MAKE_BAT Aratako/LightChatAssistant-4x7B-GGUF 4x7B_Q4_K_M 0
call :MAKE_BAT Aratako/LightChatAssistant-4x7B-GGUF 4x7B_Q4_K_M 15
call :MAKE_BAT Aratako/LightChatAssistant-4x7B-GGUF 4x7B_Q4_K_M 33

call :MAKE_BAT Aratako/LightChatAssistant-2x7B-optimized-experimental-GGUF 2x7B-optimized-experimental_Q4_K_M 0
call :MAKE_BAT Aratako/LightChatAssistant-2x7B-optimized-experimental-GGUF 2x7B-optimized-experimental_Q4_K_M 24
call :MAKE_BAT Aratako/LightChatAssistant-2x7B-optimized-experimental-GGUF 2x7B-optimized-experimental_Q4_K_M 33

echo @echo off>DeleteAllRunBats.bat
echo del Run-*.bat>>DeleteAllRunBats.bat

popd
exit /b 0

:MAKE_BAT
set REPO_ID=%1
set VARIATION=%2
set GPU_LAYERS=%3

set MODEL_FILE=LightChatAssistant-%VARIATION%.gguf
set KOBOLDCPP_ARGS=^
--model %MODEL_FILE% ^
--contextsize 32768 ^
--usecublas ^
--gpulayers %GPU_LAYERS% ^
--launch

set RUN_BAT=Run-%VARIATION%_L%GPU_LAYERS%.bat
echo @echo off>%RUN_BAT%
echo if not exist %MODEL_FILE% ( %CURL_CMD% -LO https://huggingface.co/%REPO_ID%/resolve/main/%MODEL_FILE% --ssl-no-revoke ^)>>%RUN_BAT%
echo koboldcpp.exe %KOBOLDCPP_ARGS%>>%RUN_BAT%

exit /b 0
