package com.base.common.db;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MediatorLiveData;
import androidx.lifecycle.Observer;

import com.base.common.db.entity.OpsPermissionEntity;
import com.base.common.db.entity.RoleEntity;

import java.util.List;

public class DataRepository {
    private static DataRepository sInstance;
    private final AppDatabase mDatabase;
    public  final AppExecutors mAppExecutors;

    public DataRepository(AppDatabase mDatabase, AppExecutors mAppExecutors) {
        this.mDatabase = mDatabase;
        this.mAppExecutors = mAppExecutors;
    }

    public static DataRepository getInstance(final AppDatabase database,final AppExecutors mAppExecutors) {
        if (sInstance == null) {
            synchronized (DataRepository.class) {
                if (sInstance == null) {
                    sInstance = new DataRepository(database,mAppExecutors);
                }
            }
        }
        return sInstance;
    }

    private MediatorLiveData<List<OpsPermissionEntity>> mObservableEntities;
    public LiveData<List<OpsPermissionEntity>> loadAllOpsPermissionEntities() {
        mObservableEntities = new MediatorLiveData<>();
        mObservableEntities.addSource(mDatabase.opsPermissionDao().loadAllOpsPermissionEntities(),
                productEntities -> {
//                    if (mDatabase.getDatabaseCreated().getValue() != null) {
//                        mObservableEntities.postValue(productEntities);
//                    }
                    mObservableEntities.postValue(productEntities);
                });

        return mObservableEntities;
    }
    private MediatorLiveData<OpsPermissionEntity> mObservableEntity;
    public LiveData<OpsPermissionEntity> loadAllOpsPermissionEntity(String code) {
        mObservableEntity = new MediatorLiveData<>();
        mObservableEntity.addSource(mDatabase.opsPermissionDao().loadOpsPermissionEntity(code),
                productEntity -> {
//                    if (mDatabase.getDatabaseCreated().getValue() != null) {
//                        mObservableEntity.postValue(productEntity);
//                    }
                    mObservableEntity.postValue(productEntity);
                });

        return mObservableEntity;
    }
    private MediatorLiveData<OpsPermissionEntity> mObservableEntityMonitor;
    public LiveData<OpsPermissionEntity> loadAllOpsPermissionEntityMonitor(String code) {
        mObservableEntityMonitor = new MediatorLiveData<>();
        mObservableEntityMonitor.addSource(mDatabase.opsPermissionDao().loadOpsPermissionEntity(code),
                productEntity -> {
//                    if (mDatabase.getDatabaseCreated().getValue() != null) {
//                        mObservableEntity.postValue(productEntity);
//                    }
                    mObservableEntityMonitor.postValue(productEntity);
                });

        return mObservableEntityMonitor;
    }

    public LiveData<OpsPermissionEntity> loadPermissionEntity(String code) {
        return mDatabase.opsPermissionDao().loadOpsPermissionEntity(code);
    }

    public void insertOpsPermissionEntities(List<OpsPermissionEntity> list){
        mAppExecutors.diskIO().execute( ()-> {
            mDatabase.opsPermissionDao().insertAll(list);
        });
    }

}
