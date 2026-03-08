package com.crop.management.service;

import com.crop.management.common.PageResult;
import com.crop.management.entity.TechnicalGuidance;

public interface TechnicalGuidanceService {

    PageResult<TechnicalGuidance> list(Integer page, Integer size, Long cropId, String keyword);

    TechnicalGuidance getById(Long id);

    void create(TechnicalGuidance guidance);

    void update(Long id, TechnicalGuidance guidance);

    void delete(Long id);
}
