package com.okla.ops.views.workbench.sales.depositrefund;

import android.annotation.SuppressLint
import android.net.Uri
import android.os.Bundle
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.fragment.app.DialogFragment
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager2.widget.ViewPager2
import androidx.viewpager2.widget.ViewPager2.OnPageChangeCallback
import com.base.common.utils.ToastUtils
import com.bumptech.glide.Glide
//import com.github.barteksc.pdfviewer.PDFView
import com.okla.ops.R
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.BufferedInputStream
import java.io.IOException
import java.io.InputStream
import java.net.HttpURLConnection
import java.net.URL


class ViewReceiptDialogFragment(
    private val sourceList: ArrayList<String>
) : DialogFragment() {

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_view_receipt, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val viewPager: ViewPager2 = view.findViewById(R.id.viewPager)
        val tvPageIndex: TextView = view.findViewById(R.id.tvCurrent)
        // 初始化适配器
        viewPager.adapter = MediaPagerAdapter().apply {
            submitList(sourceList)
        }
        tvPageIndex.text = "(".plus(1).plus("/").plus(sourceList.size).plus(")")
        viewPager.registerOnPageChangeCallback(object : OnPageChangeCallback() {
            override fun onPageScrollStateChanged(state: Int) {
                super.onPageScrollStateChanged(state)
            }

            override fun onPageSelected(position: Int) {
                super.onPageSelected(position)
                tvPageIndex.text = "(".plus(position + 1).plus("/").plus(sourceList.size).plus(")")
            }

            override fun onPageScrolled(
                position: Int,
                positionOffset: Float,
                positionOffsetPixels: Int
            ) {
                super.onPageScrolled(position, positionOffset, positionOffsetPixels)
            }
        })
    }

    // 新增适配器类
    private inner class MediaPagerAdapter : RecyclerView.Adapter<MediaViewHolder>() {

        private val items = mutableListOf<String>()

        @SuppressLint("NotifyDataSetChanged")
        fun submitList(list: List<String>) {
            items.clear()
            items.addAll(list)
            notifyDataSetChanged()
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MediaViewHolder {
            return MediaViewHolder(
                LayoutInflater.from(parent.context)
                    .inflate(R.layout.item_view_receipt, parent, false)
            )
        }

        override fun onBindViewHolder(holder: MediaViewHolder, position: Int) {
            holder.bind(items[position])
        }

        override fun getItemCount(): Int = items.size
    }

    private inner class MediaViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        fun bind(source: String) {
//            val pdfView: PDFView = itemView.findViewById(R.id.pdfView)
            val imageView: ImageView = itemView.findViewById(R.id.imageView)

            when {
                // 远程PDF
                source.startsWith("http", true) && source.endsWith(".pdf", true) -> {
                    imageView.visibility = View.GONE
//                    pdfView.visibility = View.VISIBLE
//                    loadRemotePdf(source, pdfView)
                }

                // 远程图片
                source.startsWith("http", true) -> {
//                    pdfView.visibility = View.GONE
                    imageView.visibility = View.VISIBLE
                    Glide.with(requireContext())
                        .load(source)
                        .into(imageView)
                }

                // 本地文件
                else -> {
                    val uri = Uri.parse(source)
                    if (source.endsWith(".pdf", true)) {
                        imageView.visibility = View.GONE
//                        pdfView.visibility = View.VISIBLE
//                        pdfView.fromUri(uri).load()
                    } else {
//                        pdfView.visibility = View.GONE
                        imageView.visibility = View.VISIBLE
                        Glide.with(this@ViewReceiptDialogFragment)
                            .load(uri)
                            .into(imageView)
                    }
                }
            }
        }

//        private fun loadRemotePdf(url: String, pdfView: PDFView) {
//            viewLifecycleOwner.lifecycleScope.launch(Dispatchers.IO) {
//                val inputStream = fetchPdfStream(url)
//                withContext(Dispatchers.Main) {
//                    inputStream?.let {
//                        pdfView.fromStream(it).load()
//                    } ?: showErrorToast()
//                }
//            }
//        }

        private fun showErrorToast() {
            ToastUtils.showShort(context?.getString(R.string.text_cannot_load_pdf_file))
        }
    }

    /** 使用 HTTPSURLConnection 获取 PDF InputStream */
    private fun fetchPdfStream(urlString: String): InputStream? {
        return try {
            val url = URL(urlString)
            (url.openConnection() as HttpURLConnection).run {
                connectTimeout = 10_000
                readTimeout = 10_000
                if (responseCode == HttpURLConnection.HTTP_OK) {
                    BufferedInputStream(inputStream)
                } else null
            }
        } catch (e: IOException) {
            e.printStackTrace()
            null
        }
    }

    override fun onStart() {
        super.onStart()
        dialog?.window?.apply {
            // 设置对话框宽度为屏幕宽度，高度为包裹内容
            // Full width, max height = 70% of screen height
            val metrics = resources.displayMetrics
            val maxHeight = (metrics.heightPixels * 7) / 10
            setLayout(
                ViewGroup.LayoutParams.MATCH_PARENT,
                maxHeight
            )
            // 设置对话框显示在底部
            setGravity(Gravity.BOTTOM)
            // 设置背景为透明
            setBackgroundDrawable(ContextCompat.getDrawable(context, R.drawable.bg_top_r16_ffffff))
            // 去除默认的边距
            decorView.setPadding(0, 0, 0, 0)
        }
    }
}