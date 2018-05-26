package com.nguyenanh.ex3.home.adapter;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.widget.BaseAdapter;
import android.widget.ImageView;

import com.nguyenanh.ex3.R;

import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.util.ArrayList;

public class AdapterListJobs extends RecyclerView.Adapter<AdapterListJobs.JobsHolder> {

    private Context context;
    private Elements elements;
    private ISaveLike iSaveLike;
    private SharedPreferences sharedPreferences;
    private ArrayList<ArrayList<String>> list = new ArrayList<>();

    public AdapterListJobs(Context context, Elements elements, ISaveLike iSaveLike, SharedPreferences sharedPreferences) {
        this.context = context;
        this.elements = elements;
        this.iSaveLike = iSaveLike;
        this.sharedPreferences = sharedPreferences;
    }

    @NonNull
    @Override
    public JobsHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.custom_jobs, parent, false);

        return new JobsHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull JobsHolder holder, int position) {
        holder.webView.loadData(elements.get(position).html(),"text/html", "UTF-8");
        String ssss = elements.get(position).id();

        SharedPreferences.Editor editor = sharedPreferences.edit();
        String like = sharedPreferences.getString(ssss, "khong");
        if (like.equals("co")){
            //editor.remove(isd);
            ArrayList<String> gg = new ArrayList<>();
            gg.add(ssss);
            gg.add("0");
            list.add(gg);
            holder.likeImage.setImageResource(R.drawable.like);
        }else {
            //editor.putString(id,"co");
            ArrayList<String> gg = new ArrayList<>();
            gg.add(ssss);
            gg.add("1");
            list.add(gg);
            holder.likeImage.setImageResource(R.drawable.unlike);
        }
        Log.d("xxxxxx", ssss);
    }

    @Override
    public int getItemCount() {
        return elements.size();
    }

    public class JobsHolder extends RecyclerView.ViewHolder implements View.OnClickListener{
        public WebView webView;
        public ImageView likeImage;

        public JobsHolder(View itemView) {
            super(itemView);
            webView = itemView.findViewById(R.id.webview);
            likeImage = itemView.findViewById(R.id.like);

            likeImage.setOnClickListener(this);
        }

        @Override
        public void onClick(View v) {
            String id = elements.get(getPosition()).id();
            iSaveLike.saveLike(id);
            for (int i = 0; i < list.size(); i++){
                if (list.get(i).get(0).equals(id)){
                    if (list.get(i).get(1).equals("0")){
                        list.remove(i);
                        ArrayList<String> gg = new ArrayList<>();
                        gg.add(id);
                        gg.add("1");
                        list.add(gg);
                        likeImage.setImageResource(R.drawable.unlike);
                    }else {
                        list.remove(i);
                        ArrayList<String> gg = new ArrayList<>();
                        gg.add(id);
                        gg.add("0");
                        list.add(gg);
                        likeImage.setImageResource(R.drawable.like);
                    }
                }
            }

        }
    }

    public interface ISaveLike{
        void saveLike(String id);
    }


}
