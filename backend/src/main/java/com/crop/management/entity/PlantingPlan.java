package com.crop.management.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("planting_plan")
public class PlantingPlan {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private Long cropId;
    private Long plotId;
    private String planName;
    private BigDecimal plannedArea;
    private LocalDate plannedStartDate;
    private LocalDate plannedEndDate;
    private LocalDate actualStartDate;
    private LocalDate actualEndDate;
    private Integer status;     // 0-待审核, 1-已通过, 2-已拒绝, 3-进行中, 4-已完成
    private String description;
    private String reviewNote;
    private Long reviewerId;
    private LocalDateTime reviewTime;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
