package com.ssafy.star.exception;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
@AllArgsConstructor
public enum CustomErrorCode {
    MAX_UPLOAD_SIZE_EXCEEDED("E0003", "업로드 가능한 파일 크기를 초과했습니다.", HttpStatus.PAYLOAD_TOO_LARGE),
    EMPTY_REFRESH_TOKEN("M0007", "Refresh Token이 비어있습니다.",HttpStatus.BAD_REQUEST),
    EMPTY_ACCESS_TOKEN("M0008", "Access Token이 비어있습니다.",HttpStatus.BAD_REQUEST),
    EXPIRED_TOKEN("M0000","만료된 토큰입니다.",HttpStatus.BAD_REQUEST),
    INVALID_TOKEN("M0009", "유효하지 않은 토큰입니다.", HttpStatus.BAD_REQUEST),
    MEMBER_INFO_NOT_MATCH("M0004", "회원정보가 일치하지 않습니다.", HttpStatus.BAD_REQUEST),
    NOT_FOUND_MESSAGE("L0001", "쪽지가 존재하지 않습니다.", HttpStatus.NOT_FOUND),
    UNAUTHORIZED_MESSAGE_ACCESS("L0002", "쪽지에 접근할 권한이 없습니다.", HttpStatus.FORBIDDEN),
    NICKNAME_ALREADY_EXISTS("M0002","이미 사용된 닉네임 입니다.", HttpStatus.BAD_REQUEST),
    MEMBER_ALREADY_EXISTS("M0001","이미 사용된 회원 ID 입니다.", HttpStatus.BAD_REQUEST),
    METHOD_NOT_ALLOWED("E0002", "지원하지 않는 메서드입니다.", HttpStatus.METHOD_NOT_ALLOWED),
    ALREADY_REPORTED_MESSAGE("L0003", "이미 신고된 쪽지입니다.", HttpStatus.BAD_REQUEST),
    NOT_FOUND_COMPLAINT_REASON("L0017", "해당 신고 사유를 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    INVALID_DATE_FORMAT("L0018", "날짜 형식이 올바르지 않습니다.", HttpStatus.BAD_REQUEST),
    INVALID_DEVICE_TOKEN("M0010", "잘못된 디바이스 토큰입니다.", HttpStatus.BAD_REQUEST),
    DEVICE_TOKEN_NOT_FOUND("M0011", "디바이스 토큰을 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    PUSH_NOTIFICATION_FAILED("P0001", "푸시 알림 전송에 실패했습니다.", HttpStatus.INTERNAL_SERVER_ERROR),
    PUSH_NOTIFICATION_INVALID_TOKEN("P0002", "유효하지 않은 디바이스 토큰입니다.", HttpStatus.BAD_REQUEST),
    PUSH_NOTIFICATION_EXPIRED_TOKEN("P0003", "만료된 디바이스 토큰입니다.", HttpStatus.BAD_REQUEST),
    PUSH_NOTIFICATION_AUTH_ERROR("P0005", "푸시 알림 인증 오류가 발생했습니다.", HttpStatus.UNAUTHORIZED),
    PUSH_NOTIFICATION_MESSAGE_TOO_LARGE("P0006", "푸시 알림 메시지 크기가 초과되었습니다.", HttpStatus.BAD_REQUEST),
    NOT_FOUND_NOTIFICATION("P0007", "알림이 존재하지 않습니다.", HttpStatus.NOT_FOUND),
    UNAUTHORIZED_NOTIFICATION_ACCESS("P0008", "알림에 접근할 권한이 없습니다.", HttpStatus.FORBIDDEN),
    ;
    private final String code;
    private final String message;
    private final HttpStatus status;
}