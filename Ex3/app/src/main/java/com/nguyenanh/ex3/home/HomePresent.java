package com.nguyenanh.ex3.home;

import com.hannesdorfmann.mosby3.mvp.MvpBasePresenter;
import com.nguyenanh.ex3.api.Provider;

import org.jsoup.nodes.Element;

import rx.Subscriber;
import rx.android.schedulers.AndroidSchedulers;
import rx.schedulers.Schedulers;


public class HomePresent extends MvpBasePresenter<HomeView> {

    public void getJobs(String skill, String local) {
        String url = "";
        if (skill.equals("")){
            url = "https://itviec.com/it-jobs/" + local;
        }else {
            url = "https://itviec.com/it-jobs/" + skill + "/" + local;
        }

        Provider.getJobs(url).subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread()).subscribe(new Subscriber<Element>() {
            @Override
            public void onCompleted() {

            }

            @Override
            public void onError(Throwable e) {
                int b = 0;
            }

            @Override
            public void onNext(Element element) {
                getView().showJobs(element);
            }
        });
    }
}
