package com.base.common.db.dao;

import androidx.lifecycle.LiveData;
import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;

import com.base.common.db.entity.OpsPermissionEntity;

import java.util.List;

@Dao
public interface OpsPermissionDao {
    @Query("SELECT * FROM opspermission")
    LiveData<List<OpsPermissionEntity>> loadAllOpsPermissionEntities();

    @Query("SELECT * FROM opspermission")
    List<OpsPermissionEntity> loadAllOpsPermissionEntities2();

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void insertAll(List<OpsPermissionEntity> opspermission);

    @Query("select * from OpsPermission where code=:code")
    LiveData<OpsPermissionEntity> loadOpsPermissionEntity(String code);
}

