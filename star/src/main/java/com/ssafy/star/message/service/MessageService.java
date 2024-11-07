package com.ssafy.star.message.service;

import com.ssafy.star.exception.CustomErrorCode;
import com.ssafy.star.exception.CustomException;
import com.ssafy.star.member.repository.MemberGroupRepository;
import com.ssafy.star.member.repository.MemberRepository;
import com.ssafy.star.message.dto.request.ComplaintMessageRequest;
import com.ssafy.star.message.dto.response.*;
import com.ssafy.star.message.entity.Complaint;
import com.ssafy.star.message.entity.ComplaintReason;
import com.ssafy.star.message.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

@Service
@Transactional(readOnly = true)
public class MessageService {
    private final MessageRepository messageRepository;
    private final MessageBoxRepository messageBoxRepository;
    private final MemberGroupRepository memberGroupRepository;
    private final MemberRepository memberRepository;
    private final ComplaintRepository complaintRepository;
    private final ComplaintReasonRepository complaintReasonRepository;
    private final GroupRepository groupRepository;

    public MessageService(MessageRepository messageRepository, MessageBoxRepository messageBoxRepository, MemberGroupRepository memberGroupRepository, ComplaintRepository complaintRepository, MemberRepository memberRepository, ComplaintReasonRepository complaintReasonRepository, GroupRepository groupRepository) {
        this.messageRepository = messageRepository;
        this.messageBoxRepository = messageBoxRepository;
        this.memberGroupRepository = memberGroupRepository;
        this.complaintReasonRepository = complaintReasonRepository;
        this.memberRepository = memberRepository;
        this.complaintRepository = complaintRepository;
        this.groupRepository = groupRepository;
    }
    LocalDateTime now = LocalDateTime.now();
    public List<ReceiveMessageListResponse> getReceiveMessageListResponse(Long userId) {

        List<ReceiveMessageListResponse> responseList = new ArrayList<>();
        responseList = messageBoxRepository.findReceivedMessageList(userId,(short) 1);
        for (ReceiveMessageListResponse res : responseList) {
            String formattedDate = formatCreatedDate(res.getCreatedAt(), now);
            res.setCreatedDate(formattedDate);
        }
        responseList.sort((m1, m2) -> m2.getCreatedAt().compareTo(m1.getCreatedAt()));

        return responseList;
    }

//    // 수신 쪽지 리스트
    public List<ReceiveMessageListResponse> getReceiveMessageList(Long userId) {

        // message_box 테이블에서 userId로 수신 쪽지 조회 하는 쿼리
        List<Long> messageIdList = messageBoxRepository.getMessageIdByMemberId(userId, (short) 1);

        // 없으면 빈 리스트 반환
        if (messageIdList == null || messageIdList.isEmpty()) {
            return new ArrayList<>();
        }

        // 반환할 리스트 초기화
        List<ReceiveMessageListResponse> list = new ArrayList<>();
        // 현재 시간을 LocalDateTime 형식으로 구함
        LocalDateTime now = LocalDateTime.now();

        // 조회한 messageId 리스트를 순회하면서 message 테이블에서 messageId 와 userId로 messageBox와 join 해서 messageBox의 state
        for (Long messageId : messageIdList) {
            List<ReceiveMessageListResponse> messages = messageRepository.findReceiveMessageListByMessageIdAndMemberId(messageId, userId);

            if (messages == null) {
                messages = new ArrayList<>();
            }

            for (ReceiveMessageListResponse message : messages) {
                String formattedDate = formatCreatedDate(message.getCreatedAt(), now);
                message.setCreatedDate(formattedDate);
            }
            list.addAll(messages);
        }

        // 날짜 기준 재정렬
        list.sort((m1, m2) -> m2.getCreatedAt().compareTo(m1.getCreatedAt()));

        return list;
    }


    // 송신 쪽지 리스트 2번째
    public List<SendMessageListResponseDto> getSendMessageListResponseDto(Long userId) {
        List<SendMessageListResponseDto> responseList = new ArrayList<>();
        responseList = messageBoxRepository.findSendMessageList(userId);

        List<SendMessageListResponse> list = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();
        // 여기서 이제 필요한게
        // 개인한테 보낸거면
        // 누구한테 보낸건지 messageBox에서 가져와






        // 우선 message 테이블은 messageId, receiver_type 으로 인덱스 설정
        for (SendMessageListResponseDto message : responseList) {

            String formattedDate = formatCreatedDate(message.getCreatedAt(), now);
            message.setCreatedDate(formattedDate);

            int messageType = message.getReceiverType();
            // 개인 한테 보낸거
            if(messageType == 0){
                String receiverNickName = messageBoxRepository.getRecipientNameByMessageId(message.getMessageId(),(short) 1);
                message.setRecipient(receiverNickName);
            }
            // 단체 한테 보냈어
            // 보물쪽지던 아니던
            // 단체면
            // OOO 외 몇명 또는 group_id로 그룹 조회 해야서 보내줘야돼
            else if(messageType == 1){
                boolean isConstructed = groupRepository.isConstructed(message.getGroupId());

                if(isConstructed){
                    String groupName = groupRepository.getConstructedGroupInfo(message.getGroupId());
                    message.setRecipient(groupName);
                }else{
                    Long result = groupRepository.countConstructed(message.getGroupId());
                    String name = groupRepository.getFirstMemberNameInGroup(message.getGroupId());
                    message.setRecipient(name+" 외 " + (result - 1) + "명");

                }
                // 단체한테 보낸거면
                // 보물쪽지면 확인한 사람이 있는지 is_find로 확인하고 그 사람 이름도 보내줘야돼
                if(message.isKind() && message.getIsFound()){
                   String receiverNickName = messageBoxRepository.getRecipientNameByMessageId(message.getMessageId(),(short) 1);
                    message.setReceiverName(receiverNickName);
                }
            }

            else if (message.isKind() && messageType == 2){
                // 불특정 다수 이면
                // 찾았는지 확인해서 그 사람 보내줘야돼
                if(message.getIsFound()){
                    String receiverNickName = messageBoxRepository.getRecipientNameByMessageId(message.getMessageId(),(short) 1);
                    message.setRecipient(receiverNickName);
                    message.setReceiverName(receiverNickName);
                }else{
                    message.setRecipient("모두에게");
                }
            }


        }


        responseList.sort((m1, m2) -> m2.getCreatedAt().compareTo(m1.getCreatedAt()));
        return responseList;
    }

    // 송신 쪽지 리스트
    public List<SendMessageListResponse> getSendMessageList(Long userId) {

        //  messageBox에서 내가 보낸 메시지 Id 리스트 가져옴
        List<Long> messageIdList = messageBoxRepository.getMessageIdByMemberId(userId, (short) 0);
        if (messageIdList == null || messageIdList.isEmpty()) {
            return new ArrayList<>();
        }

        List<SendMessageListResponse> list = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();

        for (Long messageId : messageIdList) {
            List<SendMessageListResponse> messages = messageRepository.findSendMessageListByMessageIdAndMemberId(messageId, userId);

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

        // 날짜 기준 재정렬
        list.sort((m1, m2) -> m2.getCreatedAt().compareTo(m1.getCreatedAt()));

        return list;
    }


    // 수신 쪽지 상세조회
    @Transactional
    public ReceiveMessageResponse getReceiveMessage(Long userId, Long messageId) {
        ReceiveMessageResponse receiveMessage = messageRepository.findReceiveMessageById(messageId, userId);

        if (receiveMessage == null) {
            throw new CustomException(CustomErrorCode.NOT_FOUND_MESSAGE);
        }

        if (!messageBoxRepository.existsByMessageIdAndMemberIdAndMessageDirectionAndIsDeletedFalse(messageId, userId, (short) 1)) {
            throw new CustomException(CustomErrorCode.UNAUTHORIZED_MESSAGE_ACCESS);
        }

        // 메세지 확인 여부가 false일 경우 true로 업데이트
        if (!messageBoxRepository.existsByMemberIdAndMessageIdAndStateTrue(userId, messageId)) {
            messageBoxRepository.updateStateByMessageIdAndMemberId(messageId, userId);
        }

        return receiveMessage;
    }

    // 송신 쪽지 상세조회
    public SendMessageResponse getSendMessage(Long userId, Long messageId) {
        SendMessageResponse sendMessage = messageRepository.findSendMessageById(messageId);
        if (sendMessage == null) {
            throw new CustomException(CustomErrorCode.NOT_FOUND_MESSAGE);
        }

        if (!messageBoxRepository.existsByMessageIdAndMemberIdAndMessageDirectionAndIsDeletedFalse(messageId, userId, (short) 0)) {
            throw new CustomException(CustomErrorCode.UNAUTHORIZED_MESSAGE_ACCESS);
        }

        // 받는 사람 리스트 설정
        if (sendMessage.getReceiverType() == (short) 0) {   // 한명 전송
            // 한 명 이름을 리스트로 변환 후 설정
            sendMessage.setReceiverNames(List.of(messageBoxRepository.getRecipientNameByMessageId(sendMessage.getMessageId(), (short) 0)));
        } else if (sendMessage.getReceiverType() == (short) 1) {    // 단체 or 그룹 전송
            List<String> recipients = messageBoxRepository.getRecipientNamesByMessageId(messageId, (short) 1);
            sendMessage.setReceiverNames(recipients);

            // 그룹 전송일 경우
            if (sendMessage.getGroupId() != null) {
                Boolean isConstructed = memberGroupRepository.findIsConstructedByGroupId(sendMessage.getGroupId());

                // 내가 만든 그룹이라면 그룹 이름을 설정
                if (isConstructed != null && isConstructed) {
                    String groupName = memberGroupRepository.findGroupNameById(sendMessage.getGroupId());
                    sendMessage.setReceiverNames(List.of(groupName));
                } else {
                    // 내가 만든 그룹이 아닐 경우, 기존 recipients 리스트 설정
                    sendMessage.setReceiverNames(recipients);
                }
            } else {
                // 단체 전송일 경우 recipients 리스트 설정
                sendMessage.setReceiverNames(recipients);
            }
        } else {    // 불특정 다수
            sendMessage.setReceiverNames(List.of("모두에게"));
            if (sendMessage.isKind()) { // 보물 쪽지의 경우
                if (sendMessage.isState()) {   // 누군가 쪽지를 열었을 경우
                    sendMessage.setReceiverNames(List.of(messageBoxRepository.getRecipientNameByMessageIdAndState(sendMessage.getMessageId(), (short) 1, true)));
                }
            }
        }
        return sendMessage;
    }

    // 내 쪽지함에서 쪽지 삭제
    @Transactional
    public void removeMessage(Long userId, Long messageId) {
        if (!messageRepository.existsById(messageId)) {
            throw new CustomException(CustomErrorCode.NOT_FOUND_MESSAGE);
        }
        if (!messageBoxRepository.existsByMemberIdAndMessageId(userId, messageId)) {
            throw new CustomException(CustomErrorCode.UNAUTHORIZED_MESSAGE_ACCESS);
        }
        messageBoxRepository.updateIsDeletedByMessageIdAndMemberId(messageId, userId);
    }

    // 수신 쪽지 신고하기
    @Transactional
    public void complaintMessage(Long userId, ComplaintMessageRequest request) {
        if (!messageRepository.existsById(request.getMessageId())) {
            throw new CustomException(CustomErrorCode.NOT_FOUND_MESSAGE);
        }
        if (!messageBoxRepository.existsByMemberIdAndMessageId(userId, request.getMessageId())) {
            throw new CustomException(CustomErrorCode.UNAUTHORIZED_MESSAGE_ACCESS);
        }
        if (messageBoxRepository.existsByMemberIdAndMessageIdAndIsReportedTrue(userId, request.getMessageId())) {
            throw new CustomException(CustomErrorCode.ALREADY_REPORTED_MESSAGE);
        }

        Complaint complaint = new Complaint();
        ComplaintReason complaintReason = complaintReasonRepository.findById(request.getComplaintType())
                .orElseThrow(() -> new CustomException(CustomErrorCode.NOT_FOUND_COMPLAINT_REASON));
        complaint.setReporter(memberRepository.findMemberById(userId));
        complaint.setReported(memberRepository.findMemberById(messageRepository.findSenderIdByMessageId(request.getMessageId())));
        complaint.setMessage(messageRepository.findMessageById(request.getMessageId()));
        complaint.setComplaintReason(complaintReason);
        try {
            complaint.setCreatedAt(request.getComplaintTime());
        } catch (DateTimeParseException e) {
            throw new CustomException(CustomErrorCode.INVALID_DATE_FORMAT);
        }

        complaintRepository.save(complaint);
        messageBoxRepository.updateIsReportedByMessageIdAndMemberId(request.getMessageId(), userId);
    }

    // 신고 사유 목록
    public List<ComplaintReasonResponse> complaintReasons() {
        return complaintReasonRepository.getAllComplaintReasons();
    }

    // 안 읽은 쪽지 존재 여부
    public boolean stateFalse(Long userId) {
        int count = messageBoxRepository.existsByMemberIdANDMessageDirection(userId, (short)1);
        return count != 0;
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
