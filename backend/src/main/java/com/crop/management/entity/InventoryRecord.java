package com.crop.management.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("inventory_record")
public class InventoryRecord {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long materialId;
    private Long userId;
    private Integer type;       // 1-入库(采购), 2-出库(领用)
    private BigDecimal quantity;
    private String reason;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
