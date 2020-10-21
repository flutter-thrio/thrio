/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2019 Hellobike Group
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

package com.hellobike.flutter.thrio.navigator

import android.app.Activity
import android.app.Application
import android.os.Bundle
import com.hellobike.flutter.thrio.BooleanCallback
import com.hellobike.flutter.thrio.NullableIntCallback
import java.lang.ref.WeakReference

internal object PageRoutes : Application.ActivityLifecycleCallbacks {

    private val activityHolders by lazy { mutableListOf<PageActivityHolder>() }

    private val removedActivityHolders by lazy { mutableListOf<PageActivityHolder>() }

    fun lastActivityHolder(pageId: Int): PageActivityHolder? {
        return activityHolders.lastOrNull { it.pageId == pageId }
    }

    fun lastActivityHolder(url: String? = null, index: Int? = null): PageActivityHolder? {
        return activityHolders.lastOrNull { it.hasRoute(url, index) }
    }

    fun removedByRemoveActivityHolder(pageId: Int): PageActivityHolder? {
        val index = removedActivityHolders.indexOfLast { it.pageId == pageId }
        return if (index != -1) removedActivityHolders.removeAt(index) else null
    }

    fun popToActivityHolders(url: String, index: Int?): List<PageActivityHolder> {
        val activityHolder = activityHolders.lastOrNull { it.lastRoute(url, index) != null }
                ?: return listOf()

        val activityHolderIndex = activityHolders.lastIndexOf(activityHolder)
        return activityHolders.subList(activityHolderIndex + 1, activityHolders.size).toMutableList()
    }

    fun hasRoute(pageId: Int): Boolean {
        return activityHolders.any { it.pageId == pageId && it.hasRoute() }
    }

    fun hasRoute(url: String? = null, index: Int? = null): Boolean = activityHolders.any {
        it.hasRoute(url, index)
    }

    fun lastRoute(url: String? = null, index: Int? = null): PageRoute? {
        for (i in activityHolders.size - 1 downTo 0) {
            val activityHolder = activityHolders[i]
            return activityHolder.lastRoute(url, index) ?: continue
        }
        return null
    }

    fun lastRoute(pageId: Int): PageRoute? {
        val activityHolder = activityHolders.lastOrNull { it.pageId == pageId }
        return activityHolder?.lastRoute()
    }

    fun allRoute(url: String): List<PageRoute> {
        val allRoutes = mutableListOf<PageRoute>()
        for (i in activityHolders.size - 1 downTo 0) {
            val activityHolder = activityHolders[i]
            allRoutes.addAll(activityHolder.allRoute(url))
        }
        return allRoutes.toList()
    }

    fun push(activity: Activity, route: PageRoute, result: NullableIntCallback) {
        val entrypoint = activity.intent.getEntrypoint()
        val pageId = activity.intent.getPageId()
        var activityHolder = activityHolders.lastOrNull { it.pageId == pageId }
        if (activityHolder == null) {
            activityHolder = PageActivityHolder(pageId, activity.javaClass, entrypoint).apply {
                this.activity = WeakReference(activity)
            }
            activityHolders.add(activityHolder)
        }
        activityHolder.pushByThrio = true
        activityHolder.push(route, result)
    }

    fun notify(url: String, index: Int? = null, name: String, params: Any?, result: BooleanCallback) {
        if (!hasRoute(url, index)) {
            result(false)
            return
        }

        var isMatch = false
        activityHolders.forEach { activityHolder ->
            activityHolder.notify(url, index, name, params) {
                if (it) isMatch = true
            }
        }
        result(isMatch)
    }

    fun pop(params: Any? = null, animated: Boolean, result: BooleanCallback) {
        val activityHolder = activityHolders.lastOrNull()
        if (activityHolder == null) {
            result(false)
            return
        }

        if (!activityHolder.pushByThrio) {
            activityHolder.activity?.get()?.finish()
            result(true)
        } else {
            activityHolder.pop(params, animated) { it ->
                if (it) {
                    if (!activityHolder.hasRoute()) {
                        activityHolder.activity?.get()?.let {
                            activityHolders.remove(activityHolder)
                            it.finish()
                        }
                    }
                }
                result(it)
            }
        }
    }


    fun popTo(url: String, index: Int?, animated: Boolean, result: BooleanCallback) {
        val activityHolder = activityHolders.lastOrNull { it.lastRoute(url, index) != null }
        if (activityHolder == null || activityHolder.activity?.get() == null) {
            result(false)
            return
        }

        activityHolder.popTo(url, index, animated) { ret ->
            if (ret) {
                val poppedToIndex = activityHolders.lastIndexOf(activityHolder)
                val removedByPopToHolders = activityHolders.subList(poppedToIndex + 1, activityHolders.size).toMutableList()
                val entrypoints = mutableSetOf<String>()
                for (holder in removedByPopToHolders) {
                    if (holder.entrypoint != activityHolder.entrypoint && holder.entrypoint != NAVIGATION_NATIVE_ENTRYPOINT) {
                        entrypoints.add(holder.entrypoint)
                    }
                }

                // 清理其它引擎的页面
                entrypoints.forEach { entrypoint ->
                    removedByPopToHolders.firstOrNull { holder -> holder.entrypoint == entrypoint }?.let {
                        var poppedToSettings = RouteSettings("/shit", 1)
                        for (i in poppedToIndex downTo 0) {
                            val poppedToRoute = activityHolders[i].lastRoute(entrypoint)
                            if (poppedToRoute != null) {
                                poppedToSettings = poppedToRoute.settings
                                break
                            }
                        }
                        FlutterEngineFactory.getEngine(entrypoint)?.sendChannel?.onPopTo(poppedToSettings.toArguments()) {}
                    }
                }
            }
            result(ret)
        }
    }

    fun remove(url: String, index: Int?, animated: Boolean, result: BooleanCallback) {
        val activityHolder = activityHolders.lastOrNull { it.lastRoute(url, index) != null }
        if (activityHolder == null) {
            result(false)
            return
        }

        activityHolder.remove(url, index, animated) {
            if (it) {
                if (!activityHolder.hasRoute()) {
                    val activity = activityHolder.activity?.get()
                    if (activity == null) {
                        removedActivityHolders.add(activityHolder)
                    } else {
                        activity.finish()
                    }
                }
            }
            result(it)
        }
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
        if (savedInstanceState == null) {
            var pageId = activity.intent.getPageId()
            if (pageId == NAVIGATION_PAGE_ID_NONE) {
                pageId = activity.hashCode()
                activity.intent.putExtra(NAVIGATION_PAGE_ID_KEY, pageId)
                val entrypoint = activity.intent.getEntrypoint()
                val activityHolder = PageActivityHolder(pageId, activity.javaClass, entrypoint).also {
                    it.activity = WeakReference(activity)
                }
                activityHolders.add(activityHolder)
            }
        } else {
            val pageId = savedInstanceState.getInt(NAVIGATION_PAGE_ID_KEY, NAVIGATION_PAGE_ID_NONE)
            if (pageId != NAVIGATION_PAGE_ID_NONE) {
                activity.intent.putExtra(NAVIGATION_PAGE_ID_KEY, pageId)
                val activityHolder = activityHolders.lastOrNull { it.pageId == pageId }
                activityHolder?.activity = WeakReference(activity)
            }
        }
    }

    override fun onActivityStarted(activity: Activity) {
        val pageId = activity.intent.getPageId()
        if (pageId != NAVIGATION_PAGE_ID_NONE) {
            val activityHolder = activityHolders.lastOrNull { it.pageId == pageId }
            activityHolder?.activity = WeakReference(activity)
        }
    }

    override fun onActivityPreResumed(activity: Activity) {
        val pageId = activity.intent.getPageId()
        if (pageId != NAVIGATION_PAGE_ID_NONE) {
            if (NavigationController.routeAction == RouteAction.NONE) {
                activityHolders.lastOrNull { it.pageId == pageId }?.apply {
                    willAppear()
                }
            }
        }
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
        val pageId = activity.intent.getIntExtra(NAVIGATION_PAGE_ID_KEY, NAVIGATION_PAGE_ID_NONE)
        if (pageId != NAVIGATION_PAGE_ID_NONE) {
            outState.putInt(NAVIGATION_PAGE_ID_KEY, pageId)
        }
    }

    override fun onActivityResumed(activity: Activity) {
        val pageId = activity.intent.getIntExtra(NAVIGATION_PAGE_ID_KEY, NAVIGATION_PAGE_ID_NONE)
        if (pageId != NAVIGATION_PAGE_ID_NONE) {
            val activityHolder = activityHolders.lastOrNull { it.pageId == pageId }
            activityHolder?.activity = WeakReference(activity)

            if (NavigationController.routeAction == RouteAction.NONE) {
                activityHolders.lastOrNull { it.pageId == pageId }?.apply {
                    didAppear()
                }
            }
        }
    }

    override fun onActivityPrePaused(activity: Activity) {
        val pageId = activity.intent.getIntExtra(NAVIGATION_PAGE_ID_KEY, NAVIGATION_PAGE_ID_NONE)
        if (pageId != NAVIGATION_PAGE_ID_NONE) {
            if (NavigationController.routeAction == RouteAction.NONE) {
                activityHolders.lastOrNull { it.pageId == pageId }?.apply {
                    willDisappear()
                }
            }
        }
    }

    override fun onActivityPaused(activity: Activity) {
        val pageId = activity.intent.getIntExtra(NAVIGATION_PAGE_ID_KEY, NAVIGATION_PAGE_ID_NONE)
        if (pageId != NAVIGATION_PAGE_ID_NONE) {
            if (NavigationController.routeAction == RouteAction.NONE) {
                activityHolders.lastOrNull { it.pageId == pageId }?.apply {
                    didDisappear()
                }
            }
        }
    }

    override fun onActivityStopped(activity: Activity?) {
    }

    override fun onActivityDestroyed(activity: Activity) {
        val pageId = activity.intent.getPageId()
        if (pageId != NAVIGATION_PAGE_ID_NONE) {
            activityHolders.lastOrNull { it.pageId == pageId }?.apply {
                if (activity.isFinishing) {
                    activityHolders.remove(this)
                }
                this.activity = null
            }
        }
    }
}