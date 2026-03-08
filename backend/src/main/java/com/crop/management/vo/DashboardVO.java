package com.crop.management.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Data
public class DashboardVO {
    private long userCount;
    private long cropCount;
    private long planCount;
    private long operationCount;
    private BigDecimal totalYield;
    private BigDecimal totalCost;
    private List<Map<String, Object>> planStatusDistribution;
    private List<Map<String, Object>> operationTypeDistribution;
    private List<Map<String, Object>> costTypeDistribution;
    private List<Map<String, Object>> monthlyYieldTrend;
    private List<Map<String, Object>> monthlyCostTrend;
    private List<Map<String, Object>> inventoryWarnings;
}
