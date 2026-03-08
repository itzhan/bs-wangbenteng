package com.crop.management.service;

import com.crop.management.common.PageResult;
import com.crop.management.entity.YieldRecord;

public interface YieldRecordService {

    PageResult<YieldRecord> list(Integer page, Integer size, Long planId, Long userId,
                                 String startDate, String endDate);

    YieldRecord getById(Long id);

    void create(YieldRecord record);

    void update(Long id, YieldRecord record);

    void delete(Long id);
}
