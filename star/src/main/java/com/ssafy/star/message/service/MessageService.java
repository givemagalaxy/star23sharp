package com.ssafy.star.message.service;

import com.ssafy.star.exception.CustomErrorCode;
import com.ssafy.star.exception.CustomException;
import com.ssafy.star.member.repository.MemberGroupRepository;
import com.ssafy.star.message.dto.response.ReceiveMessage;
import com.ssafy.star.message.dto.response.ReceiveMessageListResponse;
import com.ssafy.star.message.dto.response.SendMessageListResponse;
import com.ssafy.star.message.repository.MessageBoxRepository;
import com.ssafy.star.message.repository.MessageRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
@Transactional(readOnly = true)
public class MessageService {
    private final MessageRepository messageRepository;
    private final MessageBoxRepository messageBoxRepository;
    private final MemberGroupRepository memberGroupRepository;

    public MessageService(MessageRepository messageRepository, MessageBoxRepository messageBoxRepository, MemberGroupRepository memberGroupRepository) {
        this.messageRepository = messageRepository;
        this.messageBoxRepository = messageBoxRepository;
        this.memberGroupRepository = memberGroupRepository;
    }

    // 수신 쪽지 리스트
    public List<ReceiveMessageListResponse> getReceiveMessageList(Long userId) {
        List<Long> messageIdList = messageBoxRepository.getMessageIdByMemberId(userId, (short) 1);
        if (messageIdList == null || messageIdList.isEmpty()) {
            return new ArrayList<>();
        }

        List<ReceiveMessageListResponse> list = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();

        for (Long messageId : messageIdList) {
            List<ReceiveMessageListResponse> messages = messageRepository.findReceiveMessageListById(messageId);

            if (messages == null) {
                messages = new ArrayList<>();
            }

            for (ReceiveMessageListResponse message : messages) {
                String formattedDate = formatCreatedDate(message.getCreatedAt(), now);
                message.setCreatedDate(formattedDate);
            }
            list.addAll(messages);
        }
        return list;
    }

    // 송신 쪽지 리스트
    public List<SendMessageListResponse> getSendMessageList(Long userId) {
        List<Long> messageIdList = messageBoxRepository.getMessageIdByMemberId(userId, (short) 0);
        if (messageIdList == null || messageIdList.isEmpty()) {
            return new ArrayList<>();
        }

        List<SendMessageListResponse> list = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();

        for (Long messageId : messageIdList) {
            List<SendMessageListResponse> messages = messageRepository.findSendMessageListById(messageId);

            if (messages == null) {
                messages = new ArrayList<>();
            }

            for (SendMessageListResponse message : messages) {
                String formattedDate = formatCreatedDate(message.getCreatedAt(), now);
                message.setCreatedDate(formattedDate);
                
                if (message.getReceiverType() == (short) 0) {   // 한명 전송
                    message.setRecipient(messageBoxRepository.getRecipientNameByMessageId(message.getMessageId(), (short) 1));
                } else if (message.getReceiverType() == (short) 1) {    // 단체 or 그룹 전송
                    // 단체 전송
                    String recipient = messageBoxRepository.findMemberNicknameByMessageId(message.getMessageId(), (short) 1) + " 외 "
                            + (messageBoxRepository.getMemberCountByMessageId(message.getMessageId(), (short) 1) - 1) + "명";
                    // 그룹 전송
                    if (message.getGroupId() != null) {
                        Boolean isConstructed = memberGroupRepository.findIsConstructedByGroupId(message.getGroupId());
                        // 내가 만든 그룹인지 확인
                        if (isConstructed != null && isConstructed) {
                            recipient = memberGroupRepository.findGroupNameById(message.getGroupId());
                        }
                    }
                    message.setRecipient(recipient);
                } else {    // 불특정 다수
                    message.setRecipient("모두에게");
                }
            }
            list.addAll(messages);
        }
        return list;
    }
    
    // 수신 쪽지 상세조회
    public ReceiveMessage getReceiveMessage(Long userId, Long messageId) {
        // 쪽지가 존재하는지 확인
        if (!messageRepository.existsById(messageId)) {
            throw new CustomException(CustomErrorCode.NOT_FOUND_MESSAGE);
        }
        // userId가 받은 쪽지 맞는지 확인
        if (!messageBoxRepository.existsByMemberIdAndMessageId(userId, messageId)) {
            throw new CustomException(CustomErrorCode.UNAUTHORIZED_MESSAGE_ACCESS);
        }

        LocalDateTime now = LocalDateTime.now();
        ReceiveMessage receiveMessage = messageRepository.findReceiveMessageById(messageId);
        String formattedDate = formatCreatedDate(receiveMessage.getCreatedAt(), now);
        receiveMessage.setCreatedDate(formattedDate);

        return receiveMessage;
    }


    /* 중복 코드 */
    // 날짜 포맷 메서드
    private String formatCreatedDate(LocalDateTime createdAt, LocalDateTime now) {
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
        return createdAt.toLocalDate().isEqual(now.toLocalDate())
                ? createdAt.format(timeFormatter) // 오늘 날짜면 시간만
                : createdAt.format(dateFormatter); // 오늘 이전 날짜면 날짜만
    }
}
