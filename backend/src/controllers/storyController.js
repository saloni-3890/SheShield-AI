const Story = require("../models/Story");


// CREATE STORY
const createStory = async (req, res) => {
    try {
        const {
            title,
            content,
            category,
            isAnonymous,
        } = req.body;

        if (!title || !title.trim()) {
            return res.status(400).json({
                success: false,
                message: "Story title is required",
            });
        }

        if (!content || !content.trim()) {
            return res.status(400).json({
                success: false,
                message: "Story content is required",
            });
        }

        const allowedCategories = [
            "SAFETY",
            "HARASSMENT",
            "TRAVEL",
            "COLLEGE",
            "WORKPLACE",
            "ONLINE_SAFETY",
            "OTHER",
        ];

        if (category && !allowedCategories.includes(category)) {
            return res.status(400).json({
                success: false,
                message: "Invalid story category",
            });
        }

        const story = await Story.create({
            userId: req.user.id,
            title: title.trim(),
            content: content.trim(),
            category: category || "OTHER",
            isAnonymous: isAnonymous !== false,
            status: "PENDING",
        });

        return res.status(201).json({
            success: true,
            message: "Story submitted for review",
            story,
        });

    } catch (error) {
        console.error("Create story error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};


// GET APPROVED STORIES
const getStories = async (req, res) => {
    try {
        const stories = await Story.findAll({
            where: {
                status: "APPROVED",
            },
            order: [["createdAt", "DESC"]],
        });

        return res.status(200).json({
            success: true,
            stories,
        });

    } catch (error) {
        console.error("Get stories error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};


// GET MY STORIES
const getMyStories = async (req, res) => {
    try {
        const stories = await Story.findAll({
            where: {
                userId: req.user.id,
            },
            order: [["createdAt", "DESC"]],
        });

        return res.status(200).json({
            success: true,
            stories,
        });

    } catch (error) {
        console.error("Get my stories error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};


// DELETE MY STORY
const deleteStory = async (req, res) => {
    try {
        const { id } = req.params;

        const story = await Story.findOne({
            where: {
                id,
                userId: req.user.id,
            },
        });

        if (!story) {
            return res.status(404).json({
                success: false,
                message: "Story not found",
            });
        }

        await story.destroy();

        return res.status(200).json({
            success: true,
            message: "Story deleted successfully",
        });

    } catch (error) {
        console.error("Delete story error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};


module.exports = {
    createStory,
    getStories,
    getMyStories,
    deleteStory,
};