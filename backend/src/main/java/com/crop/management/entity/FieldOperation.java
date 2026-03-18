package com.crop.management.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("field_operation")
public class FieldOperation {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long planId;
    private Long userId;
    private Integer operationType;  // 1-灌溉, 2-施肥, 3-打药, 4-除草, 5-收获, 6-其他
    private LocalDate operationDate;
    private String description;
    private String images;
    private Long materialId;
    private BigDecimal materialQuantity;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
    @TableField(exist = false)
    private String planName;
    @TableField(exist = false)
    private String userName;
}
