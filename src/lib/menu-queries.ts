import { queryOptions } from "@tanstack/react-query";
import { getMenu, getDashboard, getComments } from "./menu.functions";
export const menuQuery = queryOptions({ queryKey: ["menu"], queryFn: () => getMenu() });
export const dashboardQuery = queryOptions({ queryKey: ["dashboard"], queryFn: () => getDashboard() });
export const commentsQuery = queryOptions({ queryKey: ["comments"], queryFn: () => getComments() });
