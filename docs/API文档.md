# 农作物种植生产管理系统 API 文档

## Overview
- **Base URL**: `http://localhost:8080/api`
- **Auth**: JWT Bearer Token
- **Content-Type**: `application/json`

## Error Codes
- `200`: Success
- `400`: Bad Request
- `401`: Unauthorized
- `403`: Forbidden
- `404`: Not Found
- `500`: Internal Server Error

## Response Format
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {}
}
```

## Paginated Response
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [],
    "total": 100,
    "page": 1,
    "size": 10
  }
}
```

---

## 1. Auth (认证)

### 1.1 用户登录
- **Method**: `POST`
- **Path**: `/api/auth/login`
- **Description**: 用户登录，返回JWT令牌
- **Auth**: 不需要
- **Request Body**:
```json
{
  "username": "string (必填)",
  "password": "string (必填)"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "userId": 1,
    "username": "admin",
    "realName": "管理员",
    "role": 1,
    "avatar": "http://example.com/avatar.jpg"
  }
}
```

### 1.2 用户注册
- **Method**: `POST`
- **Path**: `/api/auth/register`
- **Description**: 用户注册（种植户）
- **Auth**: 不需要
- **Request Body**:
```json
{
  "username": "string (必填)",
  "password": "string (必填)",
  "realName": "string",
  "phone": "string",
  "email": "string"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

## 2. User (用户管理)

### 2.1 分页查询用户列表
- **Method**: `GET`
- **Path**: `/api/users`
- **Description**: 分页查询用户列表
- **Auth**: 需要
- **Query Parameters**:
  - `page` (Integer, 默认值: 1): 页码
  - `size` (Integer, 默认值: 10): 每页数量
  - `keyword` (String, 可选): 关键词搜索
  - `role` (Integer, 可选): 角色筛选 (0-种植户, 1-管理员, 2-技术员)
  - `status` (Integer, 可选): 状态筛选 (0-禁用, 1-正常)
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      {
        "id": 1,
        "username": "admin",
        "realName": "管理员",
        "phone": "13800138000",
        "email": "admin@example.com",
        "avatar": "http://example.com/avatar.jpg",
        "role": 1,
        "status": 1,
        "createTime": "2024-01-01T00:00:00",
        "updateTime": "2024-01-01T00:00:00"
      }
    ],
    "total": 100,
    "page": 1,
    "size": 10
  }
}
```

### 2.2 根据ID查询用户
- **Method**: `GET`
- **Path**: `/api/users/{id}`
- **Description**: 根据ID查询用户详情
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 用户ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "username": "admin",
    "realName": "管理员",
    "phone": "13800138000",
    "email": "admin@example.com",
    "avatar": "http://example.com/avatar.jpg",
    "role": 1,
    "status": 1,
    "createTime": "2024-01-01T00:00:00",
    "updateTime": "2024-01-01T00:00:00"
  }
}
```

### 2.3 新增用户
- **Method**: `POST`
- **Path**: `/api/users`
- **Description**: 新增用户（管理员）
- **Auth**: 需要（管理员）
- **Request Body**:
```json
{
  "username": "string",
  "password": "string",
  "realName": "string",
  "phone": "string",
  "email": "string",
  "avatar": "string",
  "role": 0,
  "status": 1
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 2.4 修改用户
- **Method**: `PUT`
- **Path**: `/api/users/{id}`
- **Description**: 修改用户信息
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 用户ID
- **Request Body**:
```json
{
  "username": "string",
  "password": "string",
  "realName": "string",
  "phone": "string",
  "email": "string",
  "avatar": "string",
  "role": 0,
  "status": 1
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 2.5 删除用户
- **Method**: `DELETE`
- **Path**: `/api/users/{id}`
- **Description**: 删除用户
- **Auth**: 需要（管理员）
- **Path Parameters**:
  - `id` (Long): 用户ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 2.6 获取当前登录用户信息
- **Method**: `GET`
- **Path**: `/api/users/current`
- **Description**: 获取当前登录用户信息
- **Auth**: 需要
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "username": "admin",
    "realName": "管理员",
    "phone": "13800138000",
    "email": "admin@example.com",
    "avatar": "http://example.com/avatar.jpg",
    "role": 1,
    "status": 1,
    "createTime": "2024-01-01T00:00:00",
    "updateTime": "2024-01-01T00:00:00"
  }
}
```

### 2.7 修改当前用户个人资料
- **Method**: `PUT`
- **Path**: `/api/users/current/profile`
- **Description**: 修改当前用户个人资料
- **Auth**: 需要
- **Request Body**:
```json
{
  "username": "string",
  "realName": "string",
  "phone": "string",
  "email": "string",
  "avatar": "string"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 2.8 修改当前用户密码
- **Method**: `PUT`
- **Path**: `/api/users/current/password`
- **Description**: 修改当前用户密码
- **Auth**: 需要
- **Request Body**:
```json
{
  "oldPassword": "string (必填)",
  "newPassword": "string (必填)"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

## 3. Crop (农作物管理)

### 3.1 分页查询农作物列表
- **Method**: `GET`
- **Path**: `/api/crops`
- **Description**: 分页查询农作物列表
- **Auth**: 需要
- **Query Parameters**:
  - `page` (Integer, 默认值: 1): 页码
  - `size` (Integer, 默认值: 10): 每页数量
  - `keyword` (String, 可选): 关键词搜索
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      {
        "id": 1,
        "name": "水稻",
        "variety": "籼稻",
        "growthCycle": 120,
        "plantingSeason": "春季",
        "suitableRegion": "南方地区",
        "description": "水稻种植说明",
        "image": "http://example.com/image.jpg",
        "createTime": "2024-01-01T00:00:00",
        "updateTime": "2024-01-01T00:00:00"
      }
    ],
    "total": 50,
    "page": 1,
    "size": 10
  }
}
```

### 3.2 根据ID查询农作物
- **Method**: `GET`
- **Path**: `/api/crops/{id}`
- **Description**: 根据ID查询农作物详情
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 农作物ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "name": "水稻",
    "variety": "籼稻",
    "growthCycle": 120,
    "plantingSeason": "春季",
    "suitableRegion": "南方地区",
    "description": "水稻种植说明",
    "image": "http://example.com/image.jpg",
    "createTime": "2024-01-01T00:00:00",
    "updateTime": "2024-01-01T00:00:00"
  }
}
```

### 3.3 新增农作物
- **Method**: `POST`
- **Path**: `/api/crops`
- **Description**: 新增农作物
- **Auth**: 需要
- **Request Body**:
```json
{
  "name": "string",
  "variety": "string",
  "growthCycle": 120,
  "plantingSeason": "string",
  "suitableRegion": "string",
  "description": "string",
  "image": "string"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 3.4 修改农作物
- **Method**: `PUT`
- **Path**: `/api/crops/{id}`
- **Description**: 修改农作物信息
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 农作物ID
- **Request Body**:
```json
{
  "name": "string",
  "variety": "string",
  "growthCycle": 120,
  "plantingSeason": "string",
  "suitableRegion": "string",
  "description": "string",
  "image": "string"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 3.5 删除农作物
- **Method**: `DELETE`
- **Path**: `/api/crops/{id}`
- **Description**: 删除农作物
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 农作物ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

## 4. Plot (地块管理)

### 4.1 分页查询地块列表
- **Method**: `GET`
- **Path**: `/api/plots`
- **Description**: 分页查询地块列表
- **Auth**: 需要
- **Query Parameters**:
  - `page` (Integer, 默认值: 1): 页码
  - `size` (Integer, 默认值: 10): 每页数量
  - `keyword` (String, 可选): 关键词搜索
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      {
        "id": 1,
        "userId": 1,
        "name": "1号地块",
        "area": 10.50,
        "location": "东区",
        "soilType": "沙壤土",
        "description": "地块描述",
        "createTime": "2024-01-01T00:00:00",
        "updateTime": "2024-01-01T00:00:00"
      }
    ],
    "total": 20,
    "page": 1,
    "size": 10
  }
}
```

### 4.2 根据ID查询地块
- **Method**: `GET`
- **Path**: `/api/plots/{id}`
- **Description**: 根据ID查询地块详情
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 地块ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "userId": 1,
    "name": "1号地块",
    "area": 10.50,
    "location": "东区",
    "soilType": "沙壤土",
    "description": "地块描述",
    "createTime": "2024-01-01T00:00:00",
    "updateTime": "2024-01-01T00:00:00"
  }
}
```

### 4.3 新增地块
- **Method**: `POST`
- **Path**: `/api/plots`
- **Description**: 新增地块
- **Auth**: 需要
- **Request Body**:
```json
{
  "userId": 1,
  "name": "string",
  "area": 10.50,
  "location": "string",
  "soilType": "string",
  "description": "string"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 4.4 修改地块
- **Method**: `PUT`
- **Path**: `/api/plots/{id}`
- **Description**: 修改地块信息
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 地块ID
- **Request Body**:
```json
{
  "userId": 1,
  "name": "string",
  "area": 10.50,
  "location": "string",
  "soilType": "string",
  "description": "string"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 4.5 删除地块
- **Method**: `DELETE`
- **Path**: `/api/plots/{id}`
- **Description**: 删除地块
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 地块ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 4.6 查询当前用户的地块
- **Method**: `GET`
- **Path**: `/api/plots/my`
- **Description**: 查询当前登录用户的地块列表
- **Auth**: 需要
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": [
    {
      "id": 1,
      "userId": 1,
      "name": "1号地块",
      "area": 10.50,
      "location": "东区",
      "soilType": "沙壤土",
      "description": "地块描述",
      "createTime": "2024-01-01T00:00:00",
      "updateTime": "2024-01-01T00:00:00"
    }
  ]
}
```

---

## 5. PlantingPlan (种植计划)

### 5.1 分页查询种植计划列表
- **Method**: `GET`
- **Path**: `/api/plans`
- **Description**: 分页查询种植计划列表
- **Auth**: 需要
- **Query Parameters**:
  - `page` (Integer, 默认值: 1): 页码
  - `size` (Integer, 默认值: 10): 每页数量
  - `userId` (Long, 可选): 用户ID筛选
  - `cropId` (Long, 可选): 农作物ID筛选
  - `status` (Integer, 可选): 状态筛选 (0-待审核, 1-已通过, 2-已拒绝, 3-进行中, 4-已完成)
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      {
        "id": 1,
        "userId": 1,
        "cropId": 1,
        "plotId": 1,
        "planName": "春季水稻种植计划",
        "plannedArea": 10.50,
        "plannedStartDate": "2024-03-01",
        "plannedEndDate": "2024-07-01",
        "actualStartDate": "2024-03-05",
        "actualEndDate": null,
        "status": 3,
        "description": "计划描述",
        "reviewNote": null,
        "reviewerId": null,
        "reviewTime": null,
        "createTime": "2024-01-01T00:00:00",
        "updateTime": "2024-01-01T00:00:00"
      }
    ],
    "total": 30,
    "page": 1,
    "size": 10
  }
}
```

### 5.2 根据ID查询种植计划
- **Method**: `GET`
- **Path**: `/api/plans/{id}`
- **Description**: 根据ID查询种植计划详情
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 种植计划ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "userId": 1,
    "cropId": 1,
    "plotId": 1,
    "planName": "春季水稻种植计划",
    "plannedArea": 10.50,
    "plannedStartDate": "2024-03-01",
    "plannedEndDate": "2024-07-01",
    "actualStartDate": "2024-03-05",
    "actualEndDate": null,
    "status": 3,
    "description": "计划描述",
    "reviewNote": null,
    "reviewerId": null,
    "reviewTime": null,
    "createTime": "2024-01-01T00:00:00",
    "updateTime": "2024-01-01T00:00:00"
  }
}
```

### 5.3 新增种植计划
- **Method**: `POST`
- **Path**: `/api/plans`
- **Description**: 新增种植计划
- **Auth**: 需要
- **Request Body**:
```json
{
  "userId": 1,
  "cropId": 1,
  "plotId": 1,
  "planName": "string",
  "plannedArea": 10.50,
  "plannedStartDate": "2024-03-01",
  "plannedEndDate": "2024-07-01",
  "description": "string"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 5.4 修改种植计划
- **Method**: `PUT`
- **Path**: `/api/plans/{id}`
- **Description**: 修改种植计划信息
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 种植计划ID
- **Request Body**:
```json
{
  "userId": 1,
  "cropId": 1,
  "plotId": 1,
  "planName": "string",
  "plannedArea": 10.50,
  "plannedStartDate": "2024-03-01",
  "plannedEndDate": "2024-07-01",
  "description": "string"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 5.5 删除种植计划
- **Method**: `DELETE`
- **Path**: `/api/plans/{id}`
- **Description**: 删除种植计划
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 种植计划ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 5.6 审核种植计划
- **Method**: `PUT`
- **Path**: `/api/plans/{id}/review`
- **Description**: 审核种植计划（管理员/技术员）
- **Auth**: 需要（管理员/技术员）
- **Path Parameters**:
  - `id` (Long): 种植计划ID
- **Request Body**:
```json
{
  "status": 1,
  "reviewNote": "string"
}
```
- **说明**: status: 1-通过, 2-拒绝
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 5.7 开始执行种植计划
- **Method**: `PUT`
- **Path**: `/api/plans/{id}/start`
- **Description**: 开始执行种植计划
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 种植计划ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 5.8 完成种植计划
- **Method**: `PUT`
- **Path**: `/api/plans/{id}/complete`
- **Description**: 完成种植计划
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 种植计划ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 5.9 查询当前用户的种植计划
- **Method**: `GET`
- **Path**: `/api/plans/my`
- **Description**: 查询当前登录用户的种植计划列表
- **Auth**: 需要
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": [
    {
      "id": 1,
      "userId": 1,
      "cropId": 1,
      "plotId": 1,
      "planName": "春季水稻种植计划",
      "plannedArea": 10.50,
      "plannedStartDate": "2024-03-01",
      "plannedEndDate": "2024-07-01",
      "actualStartDate": "2024-03-05",
      "actualEndDate": null,
      "status": 3,
      "description": "计划描述",
      "reviewNote": null,
      "reviewerId": null,
      "reviewTime": null,
      "createTime": "2024-01-01T00:00:00",
      "updateTime": "2024-01-01T00:00:00"
    }
  ]
}
```

---

## 6. FieldOperation (田间操作)

### 6.1 分页查询田间操作记录
- **Method**: `GET`
- **Path**: `/api/operations`
- **Description**: 分页查询田间操作记录
- **Auth**: 需要
- **Query Parameters**:
  - `page` (Integer, 默认值: 1): 页码
  - `size` (Integer, 默认值: 10): 每页数量
  - `planId` (Long, 可选): 种植计划ID筛选
  - `userId` (Long, 可选): 用户ID筛选
  - `operationType` (Integer, 可选): 操作类型筛选 (1-灌溉, 2-施肥, 3-打药, 4-除草, 5-收获, 6-其他)
  - `startDate` (String, 可选): 开始日期 (格式: yyyy-MM-dd)
  - `endDate` (String, 可选): 结束日期 (格式: yyyy-MM-dd)
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      {
        "id": 1,
        "planId": 1,
        "userId": 1,
        "operationType": 1,
        "operationDate": "2024-03-10",
        "description": "灌溉操作描述",
        "images": "[\"http://example.com/image1.jpg\"]",
        "materialId": 1,
        "materialQuantity": 50.00,
        "createTime": "2024-03-10T10:00:00",
        "updateTime": "2024-03-10T10:00:00"
      }
    ],
    "total": 100,
    "page": 1,
    "size": 10
  }
}
```

### 6.2 根据ID查询田间操作
- **Method**: `GET`
- **Path**: `/api/operations/{id}`
- **Description**: 根据ID查询田间操作详情
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 田间操作ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "planId": 1,
    "userId": 1,
    "operationType": 1,
    "operationDate": "2024-03-10",
    "description": "灌溉操作描述",
    "images": "[\"http://example.com/image1.jpg\"]",
    "materialId": 1,
    "materialQuantity": 50.00,
    "createTime": "2024-03-10T10:00:00",
    "updateTime": "2024-03-10T10:00:00"
  }
}
```

### 6.3 新增田间操作
- **Method**: `POST`
- **Path**: `/api/operations`
- **Description**: 新增田间操作记录
- **Auth**: 需要
- **Request Body**:
```json
{
  "planId": 1,
  "userId": 1,
  "operationType": 1,
  "operationDate": "2024-03-10",
  "description": "string",
  "images": "string",
  "materialId": 1,
  "materialQuantity": 50.00
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 6.4 修改田间操作
- **Method**: `PUT`
- **Path**: `/api/operations/{id}`
- **Description**: 修改田间操作记录
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 田间操作ID
- **Request Body**:
```json
{
  "planId": 1,
  "userId": 1,
  "operationType": 1,
  "operationDate": "2024-03-10",
  "description": "string",
  "images": "string",
  "materialId": 1,
  "materialQuantity": 50.00
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 6.5 删除田间操作
- **Method**: `DELETE`
- **Path**: `/api/operations/{id}`
- **Description**: 删除田间操作记录
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 田间操作ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

## 7. Material (农资管理)

### 7.1 分页查询农资列表
- **Method**: `GET`
- **Path**: `/api/materials`
- **Description**: 分页查询农资列表
- **Auth**: 需要
- **Query Parameters**:
  - `page` (Integer, 默认值: 1): 页码
  - `size` (Integer, 默认值: 10): 每页数量
  - `keyword` (String, 可选): 关键词搜索
  - `type` (Integer, 可选): 类型筛选 (1-种子, 2-化肥, 3-农药, 4-工具, 5-其他)
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      {
        "id": 1,
        "name": "复合肥",
        "type": 2,
        "unit": "kg",
        "specification": "50kg/袋",
        "manufacturer": "XX化肥厂",
        "price": 150.00,
        "description": "农资描述",
        "image": "http://example.com/image.jpg",
        "createTime": "2024-01-01T00:00:00",
        "updateTime": "2024-01-01T00:00:00"
      }
    ],
    "total": 50,
    "page": 1,
    "size": 10
  }
}
```

### 7.2 根据ID查询农资
- **Method**: `GET`
- **Path**: `/api/materials/{id}`
- **Description**: 根据ID查询农资详情
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 农资ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "name": "复合肥",
    "type": 2,
    "unit": "kg",
    "specification": "50kg/袋",
    "manufacturer": "XX化肥厂",
    "price": 150.00,
    "description": "农资描述",
    "image": "http://example.com/image.jpg",
    "createTime": "2024-01-01T00:00:00",
    "updateTime": "2024-01-01T00:00:00"
  }
}
```

### 7.3 新增农资
- **Method**: `POST`
- **Path**: `/api/materials`
- **Description**: 新增农资
- **Auth**: 需要
- **Request Body**:
```json
{
  "name": "string",
  "type": 1,
  "unit": "string",
  "specification": "string",
  "manufacturer": "string",
  "price": 150.00,
  "description": "string",
  "image": "string"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 7.4 修改农资
- **Method**: `PUT`
- **Path**: `/api/materials/{id}`
- **Description**: 修改农资信息
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 农资ID
- **Request Body**:
```json
{
  "name": "string",
  "type": 1,
  "unit": "string",
  "specification": "string",
  "manufacturer": "string",
  "price": 150.00,
  "description": "string",
  "image": "string"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 7.5 删除农资
- **Method**: `DELETE`
- **Path**: `/api/materials/{id}`
- **Description**: 删除农资
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 农资ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

## 8. Inventory (库存管理)

### 8.1 分页查询库存列表
- **Method**: `GET`
- **Path**: `/api/inventory`
- **Description**: 分页查询库存列表
- **Auth**: 需要
- **Query Parameters**:
  - `page` (Integer, 默认值: 1): 页码
  - `size` (Integer, 默认值: 10): 每页数量
  - `materialId` (Long, 可选): 农资ID筛选
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      {
        "id": 1,
        "materialId": 1,
        "quantity": 500.00,
        "warningThreshold": 100.00,
        "createTime": "2024-01-01T00:00:00",
        "updateTime": "2024-01-01T00:00:00"
      }
    ],
    "total": 20,
    "page": 1,
    "size": 10
  }
}
```

### 8.2 获取库存预警信息
- **Method**: `GET`
- **Path**: `/api/inventory/warnings`
- **Description**: 获取库存预警信息（库存低于预警阈值）
- **Auth**: 需要
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": [
    {
      "id": 1,
      "materialId": 1,
      "quantity": 50.00,
      "warningThreshold": 100.00,
      "createTime": "2024-01-01T00:00:00",
      "updateTime": "2024-01-01T00:00:00"
    }
  ]
}
```

### 8.3 库存出入库操作
- **Method**: `POST`
- **Path**: `/api/inventory/operate`
- **Description**: 库存出入库操作
- **Auth**: 需要
- **Request Body**:
```json
{
  "materialId": 1,
  "type": 1,
  "quantity": 100.00,
  "reason": "string"
}
```
- **说明**: type: 1-入库(采购), 2-出库(领用)
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 8.4 分页查询库存操作记录
- **Method**: `GET`
- **Path**: `/api/inventory/records`
- **Description**: 分页查询库存操作记录
- **Auth**: 需要
- **Query Parameters**:
  - `page` (Integer, 默认值: 1): 页码
  - `size` (Integer, 默认值: 10): 每页数量
  - `materialId` (Long, 可选): 农资ID筛选
  - `type` (Integer, 可选): 操作类型筛选 (1-入库, 2-出库)
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      {
        "id": 1,
        "materialId": 1,
        "userId": 1,
        "type": 1,
        "quantity": 100.00,
        "reason": "采购入库",
        "createTime": "2024-01-01T10:00:00"
      }
    ],
    "total": 50,
    "page": 1,
    "size": 10
  }
}
```

---

## 9. YieldRecord (产量记录)

### 9.1 分页查询产量记录
- **Method**: `GET`
- **Path**: `/api/yields`
- **Description**: 分页查询产量记录
- **Auth**: 需要
- **Query Parameters**:
  - `page` (Integer, 默认值: 1): 页码
  - `size` (Integer, 默认值: 10): 每页数量
  - `planId` (Long, 可选): 种植计划ID筛选
  - `userId` (Long, 可选): 用户ID筛选
  - `startDate` (String, 可选): 开始日期 (格式: yyyy-MM-dd)
  - `endDate` (String, 可选): 结束日期 (格式: yyyy-MM-dd)
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      {
        "id": 1,
        "planId": 1,
        "userId": 1,
        "quantity": 5000.00,
        "unit": "kg",
        "harvestDate": "2024-07-01",
        "quality": "优质",
        "notes": "产量记录备注",
        "createTime": "2024-07-01T10:00:00",
        "updateTime": "2024-07-01T10:00:00"
      }
    ],
    "total": 30,
    "page": 1,
    "size": 10
  }
}
```

### 9.2 根据ID查询产量记录
- **Method**: `GET`
- **Path**: `/api/yields/{id}`
- **Description**: 根据ID查询产量记录详情
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 产量记录ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "planId": 1,
    "userId": 1,
    "quantity": 5000.00,
    "unit": "kg",
    "harvestDate": "2024-07-01",
    "quality": "优质",
    "notes": "产量记录备注",
    "createTime": "2024-07-01T10:00:00",
    "updateTime": "2024-07-01T10:00:00"
  }
}
```

### 9.3 新增产量记录
- **Method**: `POST`
- **Path**: `/api/yields`
- **Description**: 新增产量记录
- **Auth**: 需要
- **Request Body**:
```json
{
  "planId": 1,
  "userId": 1,
  "quantity": 5000.00,
  "unit": "kg",
  "harvestDate": "2024-07-01",
  "quality": "string",
  "notes": "string"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 9.4 修改产量记录
- **Method**: `PUT`
- **Path**: `/api/yields/{id}`
- **Description**: 修改产量记录
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 产量记录ID
- **Request Body**:
```json
{
  "planId": 1,
  "userId": 1,
  "quantity": 5000.00,
  "unit": "kg",
  "harvestDate": "2024-07-01",
  "quality": "string",
  "notes": "string"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 9.5 删除产量记录
- **Method**: `DELETE`
- **Path**: `/api/yields/{id}`
- **Description**: 删除产量记录
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 产量记录ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

## 10. CostRecord (成本记录)

### 10.1 分页查询成本记录
- **Method**: `GET`
- **Path**: `/api/costs`
- **Description**: 分页查询成本记录
- **Auth**: 需要
- **Query Parameters**:
  - `page` (Integer, 默认值: 1): 页码
  - `size` (Integer, 默认值: 10): 每页数量
  - `planId` (Long, 可选): 种植计划ID筛选
  - `userId` (Long, 可选): 用户ID筛选
  - `type` (Integer, 可选): 成本类型筛选 (1-种子, 2-化肥, 3-农药, 4-人工, 5-设备, 6-其他)
  - `startDate` (String, 可选): 开始日期 (格式: yyyy-MM-dd)
  - `endDate` (String, 可选): 结束日期 (格式: yyyy-MM-dd)
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      {
        "id": 1,
        "planId": 1,
        "userId": 1,
        "type": 2,
        "amount": 1500.00,
        "description": "化肥成本",
        "costDate": "2024-03-15",
        "createTime": "2024-03-15T10:00:00",
        "updateTime": "2024-03-15T10:00:00"
      }
    ],
    "total": 50,
    "page": 1,
    "size": 10
  }
}
```

### 10.2 根据ID查询成本记录
- **Method**: `GET`
- **Path**: `/api/costs/{id}`
- **Description**: 根据ID查询成本记录详情
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 成本记录ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "planId": 1,
    "userId": 1,
    "type": 2,
    "amount": 1500.00,
    "description": "化肥成本",
    "costDate": "2024-03-15",
    "createTime": "2024-03-15T10:00:00",
    "updateTime": "2024-03-15T10:00:00"
  }
}
```

### 10.3 新增成本记录
- **Method**: `POST`
- **Path**: `/api/costs`
- **Description**: 新增成本记录
- **Auth**: 需要
- **Request Body**:
```json
{
  "planId": 1,
  "userId": 1,
  "type": 2,
  "amount": 1500.00,
  "description": "string",
  "costDate": "2024-03-15"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 10.4 修改成本记录
- **Method**: `PUT`
- **Path**: `/api/costs/{id}`
- **Description**: 修改成本记录
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 成本记录ID
- **Request Body**:
```json
{
  "planId": 1,
  "userId": 1,
  "type": 2,
  "amount": 1500.00,
  "description": "string",
  "costDate": "2024-03-15"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 10.5 删除成本记录
- **Method**: `DELETE`
- **Path**: `/api/costs/{id}`
- **Description**: 删除成本记录
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 成本记录ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

## 11. Announcement (公告管理)

### 11.1 分页查询公告列表
- **Method**: `GET`
- **Path**: `/api/announcements`
- **Description**: 分页查询公告列表
- **Auth**: 需要
- **Query Parameters**:
  - `page` (Integer, 默认值: 1): 页码
  - `size` (Integer, 默认值: 10): 每页数量
  - `keyword` (String, 可选): 关键词搜索
  - `status` (Integer, 可选): 状态筛选 (0-草稿, 1-已发布)
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      {
        "id": 1,
        "title": "公告标题",
        "content": "公告内容",
        "publisherId": 1,
        "status": 1,
        "createTime": "2024-01-01T00:00:00",
        "updateTime": "2024-01-01T00:00:00"
      }
    ],
    "total": 20,
    "page": 1,
    "size": 10
  }
}
```

### 11.2 根据ID查询公告
- **Method**: `GET`
- **Path**: `/api/announcements/{id}`
- **Description**: 根据ID查询公告详情
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 公告ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "title": "公告标题",
    "content": "公告内容",
    "publisherId": 1,
    "status": 1,
    "createTime": "2024-01-01T00:00:00",
    "updateTime": "2024-01-01T00:00:00"
  }
}
```

### 11.3 新增公告
- **Method**: `POST`
- **Path**: `/api/announcements`
- **Description**: 新增公告
- **Auth**: 需要
- **Request Body**:
```json
{
  "title": "string",
  "content": "string",
  "publisherId": 1,
  "status": 0
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 11.4 修改公告
- **Method**: `PUT`
- **Path**: `/api/announcements/{id}`
- **Description**: 修改公告
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 公告ID
- **Request Body**:
```json
{
  "title": "string",
  "content": "string",
  "publisherId": 1,
  "status": 0
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 11.5 删除公告
- **Method**: `DELETE`
- **Path**: `/api/announcements/{id}`
- **Description**: 删除公告
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 公告ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 11.6 发布公告
- **Method**: `PUT`
- **Path**: `/api/announcements/{id}/publish`
- **Description**: 发布公告
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 公告ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 11.7 查询已发布公告列表
- **Method**: `GET`
- **Path**: `/api/announcements/published`
- **Description**: 查询已发布公告列表
- **Auth**: 需要
- **Query Parameters**:
  - `page` (Integer, 默认值: 1): 页码
  - `size` (Integer, 默认值: 10): 每页数量
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      {
        "id": 1,
        "title": "公告标题",
        "content": "公告内容",
        "publisherId": 1,
        "status": 1,
        "createTime": "2024-01-01T00:00:00",
        "updateTime": "2024-01-01T00:00:00"
      }
    ],
    "total": 10,
    "page": 1,
    "size": 10
  }
}
```

---

## 12. TechnicalGuidance (技术指导)

### 12.1 分页查询技术指导列表
- **Method**: `GET`
- **Path**: `/api/guidance`
- **Description**: 分页查询技术指导列表
- **Auth**: 需要
- **Query Parameters**:
  - `page` (Integer, 默认值: 1): 页码
  - `size` (Integer, 默认值: 10): 每页数量
  - `cropId` (Long, 可选): 农作物ID筛选
  - `keyword` (String, 可选): 关键词搜索
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      {
        "id": 1,
        "title": "水稻种植技术指导",
        "content": "技术指导内容",
        "cropId": 1,
        "authorId": 2,
        "createTime": "2024-01-01T00:00:00",
        "updateTime": "2024-01-01T00:00:00"
      }
    ],
    "total": 30,
    "page": 1,
    "size": 10
  }
}
```

### 12.2 根据ID查询技术指导
- **Method**: `GET`
- **Path**: `/api/guidance/{id}`
- **Description**: 根据ID查询技术指导详情
- **Auth**: 需要
- **Path Parameters**:
  - `id` (Long): 技术指导ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "title": "水稻种植技术指导",
    "content": "技术指导内容",
    "cropId": 1,
    "authorId": 2,
    "createTime": "2024-01-01T00:00:00",
    "updateTime": "2024-01-01T00:00:00"
  }
}
```

### 12.3 新增技术指导
- **Method**: `POST`
- **Path**: `/api/guidance`
- **Description**: 新增技术指导
- **Auth**: 需要（技术员）
- **Request Body**:
```json
{
  "title": "string",
  "content": "string",
  "cropId": 1,
  "authorId": 2
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 12.4 修改技术指导
- **Method**: `PUT`
- **Path**: `/api/guidance/{id}`
- **Description**: 修改技术指导
- **Auth**: 需要（技术员）
- **Path Parameters**:
  - `id` (Long): 技术指导ID
- **Request Body**:
```json
{
  "title": "string",
  "content": "string",
  "cropId": 1,
  "authorId": 2
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 12.5 删除技术指导
- **Method**: `DELETE`
- **Path**: `/api/guidance/{id}`
- **Description**: 删除技术指导
- **Auth**: 需要（技术员）
- **Path Parameters**:
  - `id` (Long): 技术指导ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

## 13. SystemLog (系统日志)

### 13.1 分页查询系统日志
- **Method**: `GET`
- **Path**: `/api/logs`
- **Description**: 分页查询系统日志
- **Auth**: 需要（管理员）
- **Query Parameters**:
  - `page` (Integer, 默认值: 1): 页码
  - `size` (Integer, 默认值: 10): 每页数量
  - `username` (String, 可选): 用户名筛选
  - `module` (String, 可选): 模块筛选
  - `startDate` (String, 可选): 开始日期 (格式: yyyy-MM-dd)
  - `endDate` (String, 可选): 结束日期 (格式: yyyy-MM-dd)
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      {
        "id": 1,
        "userId": 1,
        "username": "admin",
        "module": "用户管理",
        "action": "新增用户",
        "description": "新增用户：test",
        "ip": "192.168.1.1",
        "createTime": "2024-01-01T10:00:00"
      }
    ],
    "total": 1000,
    "page": 1,
    "size": 10
  }
}
```

---

## 14. SystemConfig (系统配置)

### 14.1 分页查询系统配置列表
- **Method**: `GET`
- **Path**: `/api/config`
- **Description**: 分页查询系统配置列表
- **Auth**: 需要（管理员）
- **Query Parameters**:
  - `page` (Integer, 默认值: 1): 页码
  - `size` (Integer, 默认值: 10): 每页数量
  - `keyword` (String, 可选): 关键词搜索
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      {
        "id": 1,
        "configKey": "system.name",
        "configValue": "农作物种植生产管理系统",
        "description": "系统名称",
        "createTime": "2024-01-01T00:00:00",
        "updateTime": "2024-01-01T00:00:00"
      }
    ],
    "total": 20,
    "page": 1,
    "size": 10
  }
}
```

### 14.2 根据ID查询系统配置
- **Method**: `GET`
- **Path**: `/api/config/{id}`
- **Description**: 根据ID查询系统配置详情
- **Auth**: 需要（管理员）
- **Path Parameters**:
  - `id` (Long): 配置ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "configKey": "system.name",
    "configValue": "农作物种植生产管理系统",
    "description": "系统名称",
    "createTime": "2024-01-01T00:00:00",
    "updateTime": "2024-01-01T00:00:00"
  }
}
```

### 14.3 根据key查询系统配置
- **Method**: `GET`
- **Path**: `/api/config/key/{key}`
- **Description**: 根据配置key查询系统配置
- **Auth**: 需要
- **Path Parameters**:
  - `key` (String): 配置key
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 1,
    "configKey": "system.name",
    "configValue": "农作物种植生产管理系统",
    "description": "系统名称",
    "createTime": "2024-01-01T00:00:00",
    "updateTime": "2024-01-01T00:00:00"
  }
}
```

### 14.4 新增系统配置
- **Method**: `POST`
- **Path**: `/api/config`
- **Description**: 新增系统配置
- **Auth**: 需要（管理员）
- **Request Body**:
```json
{
  "configKey": "string",
  "configValue": "string",
  "description": "string"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 14.5 修改系统配置
- **Method**: `PUT`
- **Path**: `/api/config/{id}`
- **Description**: 修改系统配置
- **Auth**: 需要（管理员）
- **Path Parameters**:
  - `id` (Long): 配置ID
- **Request Body**:
```json
{
  "configKey": "string",
  "configValue": "string",
  "description": "string"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

### 14.6 删除系统配置
- **Method**: `DELETE`
- **Path**: `/api/config/{id}`
- **Description**: 删除系统配置
- **Auth**: 需要（管理员）
- **Path Parameters**:
  - `id` (Long): 配置ID
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

## 15. Dashboard (仪表盘)

### 15.1 获取仪表盘统计数据
- **Method**: `GET`
- **Path**: `/api/dashboard`
- **Description**: 获取仪表盘统计数据
- **Auth**: 需要
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "userCount": 100,
    "cropCount": 50,
    "planCount": 200,
    "operationCount": 500,
    "totalYield": 50000.00,
    "totalCost": 100000.00,
    "planStatusDistribution": [
      {
        "status": 0,
        "count": 10
      },
      {
        "status": 1,
        "count": 50
      }
    ],
    "operationTypeDistribution": [
      {
        "type": 1,
        "count": 100
      }
    ],
    "costTypeDistribution": [
      {
        "type": 1,
        "count": 50
      }
    ],
    "monthlyYieldTrend": [
      {
        "month": "2024-01",
        "yield": 5000.00
      }
    ],
    "monthlyCostTrend": [
      {
        "month": "2024-01",
        "cost": 10000.00
      }
    ],
    "inventoryWarnings": [
      {
        "materialId": 1,
        "materialName": "复合肥",
        "quantity": 50.00,
        "warningThreshold": 100.00
      }
    ]
  }
}
```

---

## 16. File (文件管理)

### 16.1 文件上传
- **Method**: `POST`
- **Path**: `/api/files/upload`
- **Description**: 文件上传
- **Auth**: 需要
- **Content-Type**: `multipart/form-data`
- **Request Parameters**:
  - `file` (MultipartFile): 文件
- **Response**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": "http://example.com/files/uploaded-file.jpg"
}
```

---

## 附录

### 角色说明
- `0`: 种植户
- `1`: 管理员
- `2`: 技术员

### 状态说明

#### 用户状态
- `0`: 禁用
- `1`: 正常

#### 种植计划状态
- `0`: 待审核
- `1`: 已通过
- `2`: 已拒绝
- `3`: 进行中
- `4`: 已完成

#### 田间操作类型
- `1`: 灌溉
- `2`: 施肥
- `3`: 打药
- `4`: 除草
- `5`: 收获
- `6`: 其他

#### 农资类型
- `1`: 种子
- `2`: 化肥
- `3`: 农药
- `4`: 工具
- `5`: 其他

#### 库存操作类型
- `1`: 入库(采购)
- `2`: 出库(领用)

#### 成本类型
- `1`: 种子
- `2`: 化肥
- `3`: 农药
- `4`: 人工
- `5`: 设备
- `6`: 其他

#### 公告状态
- `0`: 草稿
- `1`: 已发布

### 认证说明
所有需要认证的接口都需要在请求头中添加：
```
Authorization: Bearer {token}
```

其中 `{token}` 是通过登录接口获取的JWT令牌。
