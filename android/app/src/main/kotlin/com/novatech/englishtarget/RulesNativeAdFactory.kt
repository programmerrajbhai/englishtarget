package com.novatech.englishtarget

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.NativeAdFactory

class RulesNativeAdFactory(
    private val context: Context,
) : NativeAdFactory {

    private fun dp(value: Int): Int {
        return (value * context.resources.displayMetrics.density).toInt()
    }

    private fun makeText(
        size: Float,
        color: Int,
        bold: Boolean = false,
    ): TextView {
        return TextView(context).apply {
            textSize = size
            setTextColor(color)
            if (bold) setTypeface(typeface, Typeface.BOLD)
        }
    }

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?,
    ): NativeAdView {
        val adView = NativeAdView(context).apply {
            background = GradientDrawable().apply {
                setColor(Color.WHITE)
                cornerRadius = dp(18).toFloat()
                setStroke(dp(1), Color.rgb(226, 232, 239))
            }
            clipToOutline = true
        }

        val content = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(12), dp(10), dp(12), dp(10))
        }

        val attribution = makeText(
            size = 11f,
            color = Color.rgb(75, 88, 102),
            bold = true,
        ).apply {
            text = "Ad"
            gravity = Gravity.CENTER
            background = GradientDrawable().apply {
                setColor(Color.rgb(241, 245, 249))
                cornerRadius = dp(4).toFloat()
            }
            setPadding(dp(6), dp(2), dp(6), dp(2))
        }

        content.addView(
            attribution,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ),
        )

        val header = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(0, dp(7), 0, dp(5))
        }

        val icon = ImageView(context).apply {
            scaleType = ImageView.ScaleType.CENTER_CROP
        }

        header.addView(
            icon,
            LinearLayout.LayoutParams(dp(40), dp(40)).apply {
                marginEnd = dp(9)
            },
        )
        adView.setIconView(icon)

        val titleColumn = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_VERTICAL
        }

        val headline = makeText(
            size = 15f,
            color = Color.rgb(20, 35, 55),
            bold = true,
        ).apply {
            maxLines = 2
            ellipsize = android.text.TextUtils.TruncateAt.END
        }

        val advertiser = makeText(
            size = 11f,
            color = Color.rgb(95, 108, 122),
        ).apply {
            maxLines = 1
            ellipsize = android.text.TextUtils.TruncateAt.END
        }

        titleColumn.addView(
            headline,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ),
        )

        titleColumn.addView(
            advertiser,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ).apply {
                topMargin = dp(2)
            },
        )

        header.addView(
            titleColumn,
            LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.WRAP_CONTENT,
                1f,
            ),
        )

        content.addView(
            header,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ),
        )

        adView.setHeadlineView(headline)
        adView.setAdvertiserView(advertiser)

        val body = makeText(
            size = 12f,
            color = Color.rgb(70, 82, 96),
        ).apply {
            maxLines = 2
            ellipsize = android.text.TextUtils.TruncateAt.END
        }

        content.addView(
            body,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ).apply {
                bottomMargin = dp(6)
            },
        )
        adView.setBodyView(body)

        val media = MediaView(context)

        content.addView(
            media,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dp(120),
            ).apply {
                bottomMargin = dp(7)
            },
        )
        adView.setMediaView(media)

        val callToAction = TextView(context).apply {
            gravity = Gravity.CENTER
            textSize = 13f
            setTextColor(Color.WHITE)
            setTypeface(typeface, Typeface.BOLD)
            background = GradientDrawable().apply {
                setColor(Color.rgb(13, 143, 104))
                cornerRadius = dp(10).toFloat()
            }
            setPadding(dp(12), dp(8), dp(12), dp(8))
        }

        content.addView(
            callToAction,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dp(38),
            ),
        )
        adView.setCallToActionView(callToAction)

        adView.addView(
            content,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            ),
        )

        headline.text = nativeAd.headline

        advertiser.text = nativeAd.advertiser.orEmpty()
        advertiser.visibility =
            if (nativeAd.advertiser.isNullOrBlank()) View.GONE else View.VISIBLE

        body.text = nativeAd.body.orEmpty()
        body.visibility =
            if (nativeAd.body.isNullOrBlank()) View.GONE else View.VISIBLE

        val iconDrawable = nativeAd.icon?.drawable
        if (iconDrawable == null) {
            icon.visibility = View.GONE
        } else {
            icon.setImageDrawable(iconDrawable)
            icon.visibility = View.VISIBLE
        }

        val mediaContent = nativeAd.mediaContent
        if (mediaContent == null) {
            media.visibility = View.GONE
        } else {
            media.mediaContent = mediaContent
            media.visibility = View.VISIBLE
        }

        callToAction.text = nativeAd.callToAction.orEmpty()
        callToAction.visibility =
            if (nativeAd.callToAction.isNullOrBlank()) View.GONE else View.VISIBLE

        adView.setNativeAd(nativeAd)
        return adView
    }
}