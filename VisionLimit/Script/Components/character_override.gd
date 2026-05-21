@tool
class_name CharacterOverride
extends Resource

## 角色立绘按图覆盖参数：把对应的 Texture 拖进来，并设置该图在 ItemDetail 中需要的缩放/偏移。
## 未填 texture 的条目会被忽略。
## scale = (1,1) 表示保持场景里 Character 节点原本的缩放（不放大不缩小）。
## offset = (0,0) 表示保持场景里 Character 节点原本的位置（不偏移）。

## 该条目对应的角色立绘纹理
@export var texture: Texture2D
## 缩放倍数（相对场景原始 scale 的乘数）
@export var scale: Vector2 = Vector2.ONE
## 位置偏移（相对场景原始 position 的偏移量）
@export var offset: Vector2 = Vector2.ZERO
