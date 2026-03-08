package com.crop.management.service;

import com.crop.management.common.PageResult;
import com.crop.management.dto.InventoryOperationDTO;
import com.crop.management.entity.Inventory;
import com.crop.management.entity.InventoryRecord;

import java.util.List;

public interface InventoryService {

    PageResult<Inventory> list(Integer page, Integer size, Long materialId);

    Inventory getByMaterialId(Long materialId);

    void operate(InventoryOperationDTO dto, Long userId);

    List<Inventory> getWarnings();

    PageResult<InventoryRecord> listRecords(Integer page, Integer size, Long materialId, Integer type);
}
