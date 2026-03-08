package com.crop.management.service;

import com.crop.management.common.PageResult;
import com.crop.management.entity.FieldOperation;

public interface FieldOperationService {

    PageResult<FieldOperation> list(Integer page, Integer size, Long planId, Long userId,
                                    Integer operationType, String startDate, String endDate);

    FieldOperation getById(Long id);

    void create(FieldOperation operation);

    void update(Long id, FieldOperation operation);

    void delete(Long id);
}
