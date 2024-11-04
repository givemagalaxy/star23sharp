package com.ssafy.star.message.dto.response;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@NoArgsConstructor
public class SendMessage {
    private Long messageId;
    private List<String> receiverNames;
    @JsonIgnore
    private LocalDateTime createdAt;
    private String createdDate;
    private String title;
    private String content;
    private String image;
    private boolean kind;
    private short receiverType;
    private boolean state;
    @JsonIgnore
    private Long groupId;

    public SendMessage(Long messageId, LocalDateTime createdAt, String title, String content, String image, boolean kind, short receiverType, boolean state, Long groupId) {
        this.messageId = messageId;
        this.createdAt = createdAt;
        this.title = title;
        this.content = content;
        this.image = image;
        this.kind = kind;
        this.receiverType = receiverType;
        this.state = state;
        this.groupId = groupId;
    }

    public void setCreatedDate(String createdDate) {
        this.createdDate = createdDate;
    }

    public void setReceiverNames(List<String> recipients) {
        this.receiverNames = recipients;
    }
}