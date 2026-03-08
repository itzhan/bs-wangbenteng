package com.crop.management.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class InventoryOperationDTO {
    @NotNull(message = "农资ID不能为空")
    private Long materialId;
    @NotNull(message = "操作类型不能为空")
    private Integer type;       // 1-入库, 2-出库
    @NotNull(message = "数量不能为空")
    private BigDecimal quantity;
    private String reason;
}
