package com.ssafy.star.exception.controller;

import com.ssafy.star.exception.CustomErrorCode;
import com.ssafy.star.exception.CustomException;
import com.ssafy.star.response.ApiResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice
public class CustomExceptionHandler {

    @ExceptionHandler(CustomException.class)
    public ResponseEntity<?> handleCustomException(CustomException e) {
        log.info("[handleCustomException] = {}", e.getMessage());
        String message = e.getMessage();
        String errorCode = e.getErrorCode();
        return ResponseEntity
                .status(e.getStatus())
                .body(new ApiResponse<Void>(errorCode, message));
    }

    // 잘못된 HTTP 메서드 요청 처리
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<?> handleMethodNotAllowed(HttpRequestMethodNotSupportedException e) {
        log.info("[handleMethodNotAllowed] = 지원하지 않는 메서드 요청");
        CustomErrorCode errorCode = CustomErrorCode.METHOD_NOT_ALLOWED;
        return ResponseEntity
                .status(405)
                .body(new ApiResponse<Void>(errorCode.getCode(), errorCode.getMessage()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<?> handleException(Exception e) {
        log.info("[handleException] = {}", e.getMessage());
        String message = "서버에서 에러가 발생했습니다.";
        String errorCode = "E0000";
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(new ApiResponse<>(errorCode, message,e.getMessage()));
    }

//    @ExceptionHandler(MaxUploadSizeExceededException.class)
//    public ResponseEntity<?> handleMaxSizeException(MaxUploadSizeExceededException e) {
//        log.info("[handleMaxSizeException] = 파일 크기 초과");
//        CustomErrorCode errorCode = CustomErrorCode.MAX_UPLOAD_SIZE_EXCEEDED;
//        return ResponseEntity
//                .status(errorCode.getStatus())
//                .body(new ApiResponse<Void>(errorCode.getCode(), errorCode.getMessage()));
//    }

}