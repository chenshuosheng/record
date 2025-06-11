```java
import org.apache.commons.compress.utils.IOUtils;

import javax.servlet.ReadListener;
import javax.servlet.ServletInputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Enumeration;
import java.util.HashMap;

/**
 * 解决异步共享HttpServletRequest 时 主线程先返回导致对象销毁，子线程读不到数据的情况
 */
public class RequestWrapper extends HttpServletRequestWrapper {
    private final byte[] body;
    private final HashMap<String, String> headMap;
    private final HashMap<String, String> requestParamMap;
    private final HashMap<String, Object> attributeParamMap;

    public RequestWrapper(HttpServletRequest request) throws IOException {
        super(request);
        body = IOUtils.toByteArray(request.getInputStream());
        headMap = new HashMap<>();
        requestParamMap = new HashMap<>();
        attributeParamMap = new HashMap<>();
        Enumeration<String> headNameList = request.getHeaderNames();
        while (headNameList.hasMoreElements()) {
            String key = headNameList.nextElement();
            headMap.put(key.toLowerCase(), request.getHeader(key));
        }
        Enumeration<String> parameterNameList = request.getParameterNames();
        while (parameterNameList.hasMoreElements()) {
            String key = parameterNameList.nextElement();
            requestParamMap.put(key, request.getParameter(key));
        }
        //深拷贝放入新request的attribute中
        Enumeration<String> attributeNames = request.getAttributeNames();
        while (attributeNames.hasMoreElements()) {
            String key = attributeNames.nextElement();
            attributeParamMap.put(key, request.getAttribute(key));
        }
    }

    @Override
    public BufferedReader getReader() {
        return new BufferedReader(new InputStreamReader(getInputStream()));
    }

    @Override
    public ServletInputStream getInputStream() {
        final ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(body);
        return new ServletInputStream() {
            @Override
            public int read() {
                return byteArrayInputStream.read();
            }

            @Override
            public boolean isFinished() {
                return false;
            }

            @Override
            public boolean isReady() {
                return false;
            }

            @Override
            public void setReadListener(ReadListener readListener) {
            }
        };
    }

    @Override
    public String getHeader(String name) {
        return headMap.get(name.toLowerCase());
    }

    @Override
    public String getParameter(String name) {
        return requestParamMap.get(name);
    }

    @Override
    public Object getAttribute(String name) {
        return attributeParamMap.get(name);
    }
}



调用：
import cn.choicelink.camunda.wrapper.RequestWrapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.task.TaskDecorator;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.concurrent.ThreadPoolExecutor;


@EnableAsync
@Configuration
public class ThreadConfig {
    private static final Logger LOGGER = LoggerFactory.getLogger(ThreadConfig.class);

    /**
     * 自定义线程池和HttpServletRequest 共享父子线程变量
     */
    @Bean
    public ThreadPoolTaskExecutor sharedVariableThreadPool() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(10);
        executor.setMaxPoolSize(20);
        executor.setQueueCapacity(200);
        executor.setKeepAliveSeconds(60);
        executor.setThreadNamePrefix("shareTaskExecutor-");
        executor.setWaitForTasksToCompleteOnShutdown(true);
        executor.setAwaitTerminationSeconds(60);
        // 增加 TaskDecorator 属性的配置
        executor.setTaskDecorator(new CustomTaskDecorator());
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        executor.initialize();
        return executor;
    }

    public static class CustomTaskDecorator implements TaskDecorator {
        @Override
        public Runnable decorate(Runnable runnable) {
            ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            assert requestAttributes != null;
            HttpServletRequest request = requestAttributes.getRequest();
            LOGGER.info("异步任务共享request");
            return () -> {
                try {
                    HttpServletRequest requestWrapper = new RequestWrapper(request);
                    ServletRequestAttributes servletRequestAttributes = new ServletRequestAttributes(requestWrapper);
                    RequestContextHolder.setRequestAttributes(servletRequestAttributes);
                    runnable.run();
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }finally {
                    RequestContextHolder.resetRequestAttributes();
                }
            };
        }
    }
}
```

