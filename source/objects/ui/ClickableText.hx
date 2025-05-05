package objects.ui;

import flixel.FlxG;
import flixel.text.FlxText;

/**
 * Object that can be created for making text clickable.
 */
class ClickableText extends FlxText {

    /**
     * Called when `this` clickable text is clicked on.
     */
    public var onClick:Void -> Void = () -> {};

    /**
     * Called when `this` clickable text is hovered on.
     */
    public var onHover:Void -> Void = () -> {};

    /**
     * Called when `this` clickable text's hover boundaries are no longer overlapping
     * the mouse.
     */
    public var onHoverLost:Void -> Void = () -> {};

    /**
     * X bounds for the *left* side of `this` clickable text.
     */
    public var bxl:Float;

    /**
     * X bounds for the *right* side of `this` clickable text.
     */
    public var bxr:Float;

    /**
     * Y bounds for the *top* side of `this` clickable text.
     */
    public var byt:Float;

    /**
     * Y bounds for the *bottom* side of `this` clickable text.
     */
    public var byb:Float;
    
    /**
     * Is `this` current clickable text being hovered on?
     */
    public var isHovered:Bool = false;
    
    /**
     * Constructor.
     * 
     * @param x    The X position of `this` clickable text.
     * @param y    The Y position of `this` clickable text.
     * @param text The text that is displayed for `this` clickable text. 
     */
    public function new(x:Float = 0, y:Float = 0, text:String = '') {
        super(x, y, text);
    }

    // -----------------------------
    //            METHODS
    // -----------------------------
    
    override function update(elapsed:Float) {
        super.update(elapsed);

        if (this.isHoveringOverMouse()) {
            if (!this.isHovered) {
                this.onHover();
                this.isHovered = true;
            }

            if (FlxG.mouse.justPressed) {
                this.onClick();
            }
        }

        if (!this.isHoveringOverMouse() && this.isHovered) {
            this.isHovered = false;
            this.onHoverLost();
        }
    }

    override function setPosition(x:Float = 0.0, y:Float = 0.0) {
        super.setPosition(x, y);
        this.updateHoverBounds();
    }

    /**
     * Gets `this` clickable button's hover bounds as an array.
     * @return The hover bounds as an array.
     */
    public inline function getHoverBoundsArray():Array<Float> {
        return [bxl, bxr, byt, byb];
    }

    /**
     * Sets the ***X*** hover bounds.
     * 
     * @param bxl Left X hover bound.
     * @param bxr Right X hover bound.
     */
    public function setHoverBoundsX(bxl:Float, bxr:Float):Void {
        this.bxl = bxl;
        this.bxr = bxr;
    }

    /**
     * Sets the ***Y*** hover bounds.
     * 
     * @param byt Top Y hover bound.
     * @param byb Bottom Y hover bound.
     */
    public function setHoverBoundsY(byt:Float, byb:Float):Void {
        this.byt = byt;
        this.byb = byb;
    }

    /**
     * Sets the hover bounds for all four sides of `this`
     * clickable text. 
     * 
     * @param bxl Left X hover bound.
     * @param bxr Right X hover bound.
     * @param byt Top Y hover bound.
     * @param byb Bottom Y hover bound.
     */
    public function setHoverBounds(bxl:Float, bxr:Float, byt:Float, byb:Float):Void {
        this.bxl = bxl;
        this.bxr = bxr;
        this.byt = byt;
        this.byb = byb;
    }

    /**
     * Reset the hover bounds to match `this` clickable text's hitbox.
     */
    public function updateHoverBounds():Void {
        this.bxl = this.x;
        this.bxr = this.x + this.width;
        this.byt = this.y;
        this.byb = this.y + this.height;
    }


    /**
     * Is `this` clickable text's hover bounds overlapping the mouse?
     * 
     * @return If the mouse is inside `this` clickable text's hover bounds.
     */
    public inline function isHoveringOverMouse():Bool {
        return (FlxG.mouse.x >= this.bxl) && (FlxG.mouse.y >= this.byt) && (FlxG.mouse.y <= this.byb) && (FlxG.mouse.x <= this.bxr);
    }
}
