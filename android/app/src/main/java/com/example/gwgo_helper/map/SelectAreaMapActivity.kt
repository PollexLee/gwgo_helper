package com.example.gwgo_helper.map

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.example.gwgo_helper.R

class SelectAreaMapActivity : AppCompatActivity() {

    lateinit var binding: com.example.gwgo_helper.databinding.ActivityMapSelectAreaBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_map_select_area)
    }


}