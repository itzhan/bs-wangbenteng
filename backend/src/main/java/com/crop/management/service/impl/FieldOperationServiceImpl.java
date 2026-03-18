package com.crop.management.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.crop.management.common.PageResult;
import com.crop.management.entity.FieldOperation;
import com.crop.management.entity.PlantingPlan;
import com.crop.management.entity.User;
import com.crop.management.exception.BusinessException;
import com.crop.management.mapper.FieldOperationMapper;
import com.crop.management.mapper.PlantingPlanMapper;
import com.crop.management.mapper.UserMapper;
import com.crop.management.service.FieldOperationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FieldOperationServiceImpl implements FieldOperationService {

    private final FieldOperationMapper fieldOperationMapper;
    private final PlantingPlanMapper plantingPlanMapper;
    private final UserMapper userMapper;

    @Override
    public PageResult<FieldOperation> list(Integer page, Integer size, Long planId, Long userId,
                                           Integer operationType, String startDate, String endDate) {
        Page<FieldOperation> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<FieldOperation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(planId != null, FieldOperation::getPlanId, planId);
        wrapper.eq(userId != null, FieldOperation::getUserId, userId);
        wrapper.eq(operationType != null, FieldOperation::getOperationType, operationType);
        wrapper.ge(StringUtils.hasText(startDate), FieldOperation::getOperationDate, 
                   StringUtils.hasText(startDate) ? LocalDate.parse(startDate) : null);
        wrapper.le(StringUtils.hasText(endDate), FieldOperation::getOperationDate, 
                   StringUtils.hasText(endDate) ? LocalDate.parse(endDate) : null);
        wrapper.orderByDesc(FieldOperation::getOperationDate);
        Page<FieldOperation> result = fieldOperationMapper.selectPage(pageParam, wrapper);
        fillDisplayFields(result.getRecords());
        return PageResult.of(result.getRecords(), result.getTotal(), page, size);
    }

    @Override
    public FieldOperation getById(Long id) {
        FieldOperation operation = fieldOperationMapper.selectById(id);
        if (operation == null) {
            throw new BusinessException("田间操作记录不存在");
        }
        return operation;
    }

    @Override
    public void create(FieldOperation operation) {
        fieldOperationMapper.insert(operation);
    }

    @Override
    public void update(Long id, FieldOperation operation) {
        FieldOperation existing = fieldOperationMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException("田间操作记录不存在");
        }
        operation.setId(id);
        fieldOperationMapper.updateById(operation);
    }

    @Override
    public void delete(Long id) {
        FieldOperation operation = fieldOperationMapper.selectById(id);
        if (operation == null) {
            throw new BusinessException("田间操作记录不存在");
        }
        fieldOperationMapper.deleteById(id);
    }

    private void fillDisplayFields(List<FieldOperation> operations) {
        if (operations == null || operations.isEmpty()) {
            return;
        }

        Map<Long, String> planNameMap = plantingPlanMapper.selectBatchIds(extractIds(operations.stream().map(FieldOperation::getPlanId).toList()))
                .stream()
                .collect(Collectors.toMap(PlantingPlan::getId, PlantingPlan::getPlanName));
        Map<Long, String> userNameMap = userMapper.selectBatchIds(extractIds(operations.stream().map(FieldOperation::getUserId).toList()))
                .stream()
                .collect(Collectors.toMap(User::getId, user -> user.getRealName() != null ? user.getRealName() : user.getUsername()));

        operations.forEach(operation -> {
            operation.setPlanName(planNameMap.get(operation.getPlanId()));
            operation.setUserName(userNameMap.get(operation.getUserId()));
        });
    }

    private Set<Long> extractIds(List<Long> ids) {
        return ids.stream().filter(Objects::nonNull).collect(Collectors.toSet());
    }
}
