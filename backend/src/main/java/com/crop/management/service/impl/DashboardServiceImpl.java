package com.crop.management.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.crop.management.entity.*;
import com.crop.management.mapper.*;
import com.crop.management.service.DashboardService;
import com.crop.management.vo.DashboardVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DashboardServiceImpl implements DashboardService {

    private final UserMapper userMapper;
    private final CropMapper cropMapper;
    private final PlantingPlanMapper plantingPlanMapper;
    private final FieldOperationMapper fieldOperationMapper;
    private final YieldRecordMapper yieldRecordMapper;
    private final CostRecordMapper costRecordMapper;
    private final InventoryMapper inventoryMapper;

    @Override
    public DashboardVO getDashboardData() {
        DashboardVO vo = new DashboardVO();

        // 基础统计
        vo.setUserCount(userMapper.selectCount(null));
        vo.setCropCount(cropMapper.selectCount(null));
        vo.setPlanCount(plantingPlanMapper.selectCount(null));
        vo.setOperationCount(fieldOperationMapper.selectCount(null));

        // 总产量
        List<YieldRecord> yieldRecords = yieldRecordMapper.selectList(null);
        BigDecimal totalYield = yieldRecords.stream()
                .map(YieldRecord::getQuantity)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        vo.setTotalYield(totalYield);

        // 总成本
        List<CostRecord> costRecords = costRecordMapper.selectList(null);
        BigDecimal totalCost = costRecords.stream()
                .map(CostRecord::getAmount)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        vo.setTotalCost(totalCost);

        // 计划状态分布
        List<PlantingPlan> plans = plantingPlanMapper.selectList(null);
        Map<Integer, Long> planStatusMap = plans.stream()
                .collect(Collectors.groupingBy(PlantingPlan::getStatus, Collectors.counting()));
        String[] planStatusNames = {"待审核", "已通过", "已拒绝", "进行中", "已完成"};
        List<Map<String, Object>> planStatusDistribution = new ArrayList<>();
        for (int i = 0; i < planStatusNames.length; i++) {
            Map<String, Object> item = new HashMap<>();
            item.put("name", planStatusNames[i]);
            item.put("value", planStatusMap.getOrDefault(i, 0L));
            planStatusDistribution.add(item);
        }
        vo.setPlanStatusDistribution(planStatusDistribution);

        // 操作类型分布
        List<FieldOperation> operations = fieldOperationMapper.selectList(null);
        Map<Integer, Long> opTypeMap = operations.stream()
                .filter(op -> op.getOperationType() != null)
                .collect(Collectors.groupingBy(FieldOperation::getOperationType, Collectors.counting()));
        String[] opTypeNames = {"", "灌溉", "施肥", "打药", "除草", "收获", "其他"};
        List<Map<String, Object>> opTypeDistribution = new ArrayList<>();
        for (int i = 1; i < opTypeNames.length; i++) {
            Map<String, Object> item = new HashMap<>();
            item.put("name", opTypeNames[i]);
            item.put("value", opTypeMap.getOrDefault(i, 0L));
            opTypeDistribution.add(item);
        }
        vo.setOperationTypeDistribution(opTypeDistribution);

        // 成本类型分布
        Map<Integer, BigDecimal> costTypeMap = costRecords.stream()
                .filter(c -> c.getType() != null && c.getAmount() != null)
                .collect(Collectors.groupingBy(CostRecord::getType,
                         Collectors.reducing(BigDecimal.ZERO, CostRecord::getAmount, BigDecimal::add)));
        String[] costTypeNames = {"", "种子", "化肥", "农药", "人工", "设备", "其他"};
        List<Map<String, Object>> costTypeDistribution = new ArrayList<>();
        for (int i = 1; i < costTypeNames.length; i++) {
            Map<String, Object> item = new HashMap<>();
            item.put("name", costTypeNames[i]);
            item.put("value", costTypeMap.getOrDefault(i, BigDecimal.ZERO));
            costTypeDistribution.add(item);
        }
        vo.setCostTypeDistribution(costTypeDistribution);

        // 月度产量趋势（近12个月）
        Map<String, BigDecimal> monthlyYield = yieldRecords.stream()
                .filter(r -> r.getHarvestDate() != null && r.getQuantity() != null)
                .collect(Collectors.groupingBy(
                        r -> r.getHarvestDate().getYear() + "-" +
                             String.format("%02d", r.getHarvestDate().getMonthValue()),
                        Collectors.reducing(BigDecimal.ZERO, YieldRecord::getQuantity, BigDecimal::add)));
        List<Map<String, Object>> monthlyYieldTrend = monthlyYield.entrySet().stream()
                .sorted(Map.Entry.comparingByKey())
                .map(e -> {
                    Map<String, Object> item = new HashMap<>();
                    item.put("month", e.getKey());
                    item.put("value", e.getValue());
                    return item;
                })
                .collect(Collectors.toList());
        vo.setMonthlyYieldTrend(monthlyYieldTrend);

        // 月度成本趋势
        Map<String, BigDecimal> monthlyCost = costRecords.stream()
                .filter(r -> r.getCostDate() != null && r.getAmount() != null)
                .collect(Collectors.groupingBy(
                        r -> r.getCostDate().getYear() + "-" +
                             String.format("%02d", r.getCostDate().getMonthValue()),
                        Collectors.reducing(BigDecimal.ZERO, CostRecord::getAmount, BigDecimal::add)));
        List<Map<String, Object>> monthlyCostTrend = monthlyCost.entrySet().stream()
                .sorted(Map.Entry.comparingByKey())
                .map(e -> {
                    Map<String, Object> item = new HashMap<>();
                    item.put("month", e.getKey());
                    item.put("value", e.getValue());
                    return item;
                })
                .collect(Collectors.toList());
        vo.setMonthlyCostTrend(monthlyCostTrend);

        // 库存预警
        LambdaQueryWrapper<Inventory> warningWrapper = new LambdaQueryWrapper<>();
        warningWrapper.apply("quantity < warning_threshold");
        List<Inventory> warningInventories = inventoryMapper.selectList(warningWrapper);
        List<Map<String, Object>> inventoryWarnings = warningInventories.stream()
                .map(inv -> {
                    Map<String, Object> item = new HashMap<>();
                    item.put("materialId", inv.getMaterialId());
                    item.put("quantity", inv.getQuantity());
                    item.put("threshold", inv.getWarningThreshold());
                    return item;
                })
                .collect(Collectors.toList());
        vo.setInventoryWarnings(inventoryWarnings);

        return vo;
    }
}
