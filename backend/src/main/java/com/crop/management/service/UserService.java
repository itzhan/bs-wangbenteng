package com.crop.management.service;

import com.crop.management.common.PageResult;
import com.crop.management.dto.PasswordDTO;
import com.crop.management.dto.RegisterDTO;
import com.crop.management.dto.UserDTO;
import com.crop.management.entity.User;

public interface UserService {

    PageResult<User> list(Integer page, Integer size, String keyword, Integer role, Integer status);

    User getById(Long id);

    void create(UserDTO dto);

    void update(Long id, UserDTO dto);

    void delete(Long id);

    void updatePassword(Long userId, PasswordDTO dto);

    void updateProfile(Long userId, UserDTO dto);

    User getCurrentUser(Long userId);

    void register(RegisterDTO dto);
}
