```java
package cn.choicelink.communal.dto;

import com.alibaba.fastjson.JSONArray;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;

@ApiModel(description = "备份更新数据参数对象")
public class BakAndUpdateModuleDto {

    @ApiModelProperty(value = "过滤demandList数据filter")
    private String filter;

    @ApiModelProperty(value = "新模块数据")
    private JSONArray moduleData;

    @ApiModelProperty(value = "模块名称")
    private String moduleName;

    @ApiModelProperty("备份模块名称")
    private String bakModuleName;

    public String getFilter() {
        return filter;
    }

    public void setFilter(String filter) {
        this.filter = filter;
    }

    public JSONArray getModuleData() {
        return moduleData;
    }

    public void setModuleData(JSONArray moduleData) {
        this.moduleData = moduleData;
    }

    public String getModuleName() {
        return moduleName;
    }

    public void setModuleName(String moduleName) {
        this.moduleName = moduleName;
    }

    public String getBakModuleName() {
        return bakModuleName;
    }

    public void setBakModuleName(String bakModuleName) {
        this.bakModuleName = bakModuleName;
    }
}

```



```java
    @ApiOperation(value = "备份更新数据")
    @PostMapping("/bakAndUpdateModuleDatas")
    public ResponseEntity<ResultVo<String>> bakAndUpdateModuleDatas(@ApiParam(hidden = true) Long userId, @RequestBody BakAndUpdateModuleDto dto){
        try {
            demandListService.bakAndUpdateModuleDatas(userId, dto);
            return new ResponseEntity<>(new ResultVo<>(true, null, "SUCCESS"), HttpStatus.OK);
        } catch (Exception e) {
            e.printStackTrace();
            return new ResponseEntity<>(new ResultVo<>(false, e.getMessage(), null), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
```



```java
public interface DemandListService extends IService<DemandList> {

        void bakAndUpdateModuleDatas(Long userId, BakAndUpdateModuleDto dto);
}

```



```java
@Service
public class DemandListServiceImpl extends ServiceImpl<DemandListMapper, DemandList> implements DemandListService {
	@Override
    public void bakAndUpdateModuleDatas(Long userId, BakAndUpdateModuleDto dto) {
        String filter = dto.getFilter();
        ListResult<DemandList> list = this.list(filter, null);
        List<DemandList> items = list.getItems();
        if (items != null && !items.isEmpty()) {
            for (DemandList item : items) {
                String id = item.getId();
                ResultVo<Object> objectResultVo = sqliteBusinessService.find(SQLITE_FILTER_VALUE, userId, id, "[\"" + dto.getModuleName() + "\"]");
                if (objectResultVo.isSuccess()) {
                    Object result = objectResultVo.getResult();
                    if (result != null) {
                        // 先将 result 转换为 JSON 字符串，再解析为 JSONObject
                        JSONObject jsonObject = JSONObject.parseObject(JSONObject.toJSONString(result));
                        JSONArray o = jsonObject.getJSONArray(dto.getModuleName());
                        if (o != null) {
                            InsertDto insertDto = new InsertDto();
                            insertDto.setPid(id);
                            insertDto.setModuleName(dto.getBakModuleName());
                            insertDto.setData(o);
                            sqliteBusinessService.insertAllFields(SQLITE_FILTER_VALUE, userId, insertDto);

                            insertDto = new InsertDto();
                            insertDto.setPid(id);
                            insertDto.setModuleName(dto.getModuleName());
                            insertDto.setData(dto.getModuleData());
                            sqliteBusinessService.insertAllFields(SQLITE_FILTER_VALUE, userId, insertDto);
                        }
                    }
                }
            }
        }
    }
}
```



```java
@Component
@FeignClient(name = "SQLITEBUSINESS")
public interface SqliteBusinessService {
    // 新增
    @PostMapping("/api/v2/insertAllFields")
    JSONObject insertAllFields(@RequestHeader(value = SQLITE_FILTER_KEY) String sqliteFilter, @RequestHeader(value = USER_ID_KEY) Long userId, @RequestBody InsertDto moduleData);

}
```

