package com.crop.management.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.crop.management.common.PageResult;
import com.crop.management.entity.Crop;
import com.crop.management.entity.TechnicalGuidance;
import com.crop.management.entity.User;
import com.crop.management.exception.BusinessException;
import com.crop.management.mapper.CropMapper;
import com.crop.management.mapper.TechnicalGuidanceMapper;
import com.crop.management.mapper.UserMapper;
import com.crop.management.service.TechnicalGuidanceService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TechnicalGuidanceServiceImpl implements TechnicalGuidanceService {

    private final TechnicalGuidanceMapper technicalGuidanceMapper;
    private final CropMapper cropMapper;
    private final UserMapper userMapper;

    @Override
    public PageResult<TechnicalGuidance> list(Integer page, Integer size, Long cropId, String keyword) {
        Page<TechnicalGuidance> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<TechnicalGuidance> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(cropId != null, TechnicalGuidance::getCropId, cropId);
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w.like(TechnicalGuidance::getTitle, keyword)
                              .or()
                              .like(TechnicalGuidance::getContent, keyword));
        }
        wrapper.orderByDesc(TechnicalGuidance::getCreateTime);
        Page<TechnicalGuidance> result = technicalGuidanceMapper.selectPage(pageParam, wrapper);
        fillDisplayFields(result.getRecords());
        return PageResult.of(result.getRecords(), result.getTotal(), page, size);
    }

    @Override
    public TechnicalGuidance getById(Long id) {
        TechnicalGuidance guidance = technicalGuidanceMapper.selectById(id);
        if (guidance == null) {
            throw new BusinessException("技术指导不存在");
        }
        return guidance;
    }

    @Override
    public void create(TechnicalGuidance guidance) {
        technicalGuidanceMapper.insert(guidance);
    }

    @Override
    public void update(Long id, TechnicalGuidance guidance) {
        TechnicalGuidance existing = technicalGuidanceMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException("技术指导不存在");
        }
        if (guidance.getAuthorId() == null) {
            guidance.setAuthorId(existing.getAuthorId());
        }
        guidance.setId(id);
        technicalGuidanceMapper.updateById(guidance);
    }

    @Override
    public void delete(Long id) {
        TechnicalGuidance guidance = technicalGuidanceMapper.selectById(id);
        if (guidance == null) {
            throw new BusinessException("技术指导不存在");
        }
        technicalGuidanceMapper.deleteById(id);
    }

    private void fillDisplayFields(List<TechnicalGuidance> guidances) {
        if (guidances == null || guidances.isEmpty()) {
            return;
        }

        Map<Long, String> cropNameMap = cropMapper.selectBatchIds(extractIds(guidances.stream().map(TechnicalGuidance::getCropId).toList()))
                .stream()
                .collect(Collectors.toMap(Crop::getId, Crop::getName));
        Map<Long, String> authorNameMap = userMapper.selectBatchIds(extractIds(guidances.stream().map(TechnicalGuidance::getAuthorId).toList()))
                .stream()
                .collect(Collectors.toMap(User::getId, user -> user.getRealName() != null ? user.getRealName() : user.getUsername()));

        guidances.forEach(guidance -> {
            guidance.setCropName(cropNameMap.get(guidance.getCropId()));
            guidance.setAuthorName(authorNameMap.get(guidance.getAuthorId()));
        });
    }

    private Set<Long> extractIds(List<Long> ids) {
        return ids.stream().filter(Objects::nonNull).collect(Collectors.toSet());
    }
}
