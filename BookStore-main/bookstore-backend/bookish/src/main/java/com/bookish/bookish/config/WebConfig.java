package com.bookish.bookish.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${upload.dir:uploads}")
    private String uploadDir;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Chỉ đích danh đường dẫn tuyệt đối tới thư mục uploads trên máy tính của bạn
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:D:/document/KiemThuPhanMem/BookStore_14/bookstore-backend/bookish/uploads/");
    }
}
