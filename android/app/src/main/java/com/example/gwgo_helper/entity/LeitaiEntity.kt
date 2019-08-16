package com.example.gwgo_helper.entity

data class LeitaiEntity(var starlevel: Int? = null, var latitude: Int, var longtitude: Int, var freshtime: Int? = null,
                        var bosslevel: Int? = null, var bossid: Int? = null, var bossfightpower: Int? = null,
                        var sprite_list: List<SpriteEntity>? = null, var winner_name: String? = null, var winner_fightpower: Int? = null,
                        var bossname: String? = null) {
    fun getSpritesFightPower(): Int {
        var power = 0
        if (sprite_list.isNullOrEmpty()) {
            return power
        }
        sprite_list!!.forEach {
            power += it.fightpower!!
        }
        return power
    }

    fun getSpritesInfo(): String {
        if (sprite_list.isNullOrEmpty()) {
            return ""
        }
        var info = ""
        sprite_list!!.forEach {
            info += "${it.name} ${it.fightpower} ${it.level}级\n"
        }
        info += "总战力${getSpritesFightPower()}"
        return info
    }
}

data class SpriteEntity(var level: Int? = null, var fightpower: Int? = null, var spriteid: Int? = null, var name: String? = null)