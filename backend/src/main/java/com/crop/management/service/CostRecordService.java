package com.crop.management.service;

import com.crop.management.common.PageResult;
import com.crop.management.entity.CostRecord;

public interface CostRecordService {

    PageResult<CostRecord> list(Integer page, Integer size, Long planId, Long userId,
                                Integer type, String startDate, String endDate);

    CostRecord getById(Long id);

    void create(CostRecord record);

    void update(Long id, CostRecord record);

    void delete(Long id);
}
