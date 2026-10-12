pragma ComponentBehavior: Bound

import QtQuick
import "FoundrySprites.js" as Sprites

// The snake from the classic game, patrolling the grid lines along the bottom
// of the screen, with a wormhole turning at either end.
Item {
    id: root
    anchors.fill: parent

    readonly property int px: Math.max(6, Math.round(height / 115))
    // One body segment. Derived from the width rather than the sprite size
    // so the whole route — and the wormhole closing it — always fits the
    // screen, whatever its aspect ratio.
    readonly property int step: Math.max(6, Math.floor((width * 0.88) / Math.max(1, totalSteps)))
    // Leg lengths of the route, in segments: right, up, right, down, right.
    readonly property var legs: [
        { "dx": 1, "dy": 0, "n": 22 },
        { "dx": 0, "dy": -1, "n": 5 },
        { "dx": 1, "dy": 0, "n": 16 },
        { "dx": 0, "dy": 1, "n": 5 },
        { "dx": 1, "dy": 0, "n": 20 }
    ]
    readonly property int totalSteps: {
        var n = 0
        for (var i = 0; i < legs.length; i++) n += legs[i].n
        return n
    }
    readonly property int bodyLength: 16
    readonly property real lane: height * 0.84

    // The head walks a fixed serpentine; the body is the head's recent history,
    // which is exactly how the site's snake is built.
    property real travel: 0
    NumberAnimation on travel {
        from: 0
        to: 1
        duration: 34000
        loops: Animation.Infinite
        running: true
    }

    /** Position of the snake `back` segments behind the head, in pixels. */
    function segmentAt(back) {
        var s = Math.floor(travel * totalSteps) - back
        var x = 0, y = 0
        if (s < 0)
            return { "x": -1000, "y": 0 }   // not on the board yet
        var remaining = s
        for (var i = 0; i < legs.length; i++) {
            var take = Math.min(remaining, legs[i].n)
            x += legs[i].dx * take * step
            y += legs[i].dy * take * step
            remaining -= take
            if (remaining <= 0)
                break
        }
        return { "x": x, "y": y }
    }

    Item {
        id: board
        x: root.width * 0.04
        y: root.lane

        Repeater {
            model: root.bodyLength
            delegate: Rectangle {
                required property int index
                readonly property var pos: root.segmentAt(index)
                x: pos.x
                y: pos.y
                width: root.step - 2
                height: root.step - 2
                // Scales alternate two greens and fade towards the tail.
                color: index === 0 ? Sprites.PALETTE[0]
                                   : (index % 2 ? "#8fbf00" : Sprites.PALETTE[0])
                opacity: index === 0 ? 1.0 : 1.0 - (index / root.bodyLength) * 0.65
                visible: pos.x > -500
            }
        }

        // The head's eye and tongue, pinned to the leading segment.
        Item {
            readonly property var pos: root.segmentAt(0)
            x: pos.x
            y: pos.y
            visible: pos.x > -500

            Rectangle {
                x: root.step * 0.55
                y: root.step * 0.25
                width: Math.max(2, root.px)
                height: Math.max(2, root.px)
                color: Sprites.BG
            }
            Rectangle {
                x: root.step
                y: root.step * 0.42
                width: root.px * 2
                height: Math.max(2, root.px * 0.6)
                color: Sprites.PALETTE[3]
            }
        }

        // Wormholes: three concentric rings, pink and cyan, turning opposite
        // ways around a dark core.
        Repeater {
            model: 2
            delegate: Item {
                id: hole
                required property int index
                x: index === 0 ? 0 : root.legs[0].n * root.step + root.legs[2].n * root.step + root.legs[4].n * root.step
                y: 0

                Repeater {
                    model: 3
                    delegate: Item {
                        id: ringItem
                        required property int index
                        readonly property real radius: (index + 1) * root.px * 3.4
                        readonly property int count: 6 + index * 4
                        rotation: spin.a * (index % 2 ? -1 : 1)

                        Repeater {
                            model: ringItem.count
                            delegate: Rectangle {
                                required property int index
                                width: Math.max(2, root.px)
                                height: Math.max(2, root.px)
                                color: (index + ringItem.index) % 2 ? Sprites.PALETTE[3] : Sprites.PALETTE[2]
                                opacity: 0.9 - ringItem.index * 0.2
                                x: Math.cos(index * 2 * Math.PI / ringItem.count) * ringItem.radius
                                y: Math.sin(index * 2 * Math.PI / ringItem.count) * ringItem.radius
                            }
                        }
                    }
                }

                Rectangle {
                    width: root.px * 2
                    height: root.px * 2
                    x: -root.px
                    y: -root.px
                    color: "#050508"
                }
            }
        }
    }

    QtObject {
        id: spin
        property real a: 0
    }
    NumberAnimation {
        target: spin
        property: "a"
        from: 0
        to: 360
        duration: 7000
        loops: Animation.Infinite
        running: true
    }

    // Beetles keeping out of its way, lower down.
    Repeater {
        model: 2
        delegate: Item {
            id: runner
            required property int index

            property real t: 0
            NumberAnimation on t {
                from: 0
                to: 1
                duration: 16000 + runner.index * 4200
                loops: Animation.Infinite
                running: true
            }
            width: bug.implicitWidth
            height: bug.implicitHeight
            x: root.width + width - ((t + index / 2) % 1) * (root.width + width * 2)
            y: root.height * 0.93 - height

            FoundryPixel {
                id: bug
                px: root.px
                flip: true
                frames: Sprites.BUG_RUN
                frameIndex: scuttle.value
                colors: Sprites.bugColors(Sprites.PALETTE[(runner.index + 2) % Sprites.PALETTE.length])
                outlinePx: 2
                outlineColor: Sprites.BG
            }
            QtObject { id: scuttle; property int value: 0 }
            Timer { interval: 95; running: true; repeat: true; onTriggered: scuttle.value = scuttle.value + 1 }
        }
    }
}
